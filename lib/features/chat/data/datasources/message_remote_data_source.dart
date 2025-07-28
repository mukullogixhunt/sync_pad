

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:sync_pad/core/error/exceptions.dart';
import '../models/messages_model.dart'; // Ensure this model is correct

abstract class MessageRemoteDataSource {
  Stream<List<MessagesModel>> getChatMessages(String docId);
  Future<void> sendTextMessage(String chatId, String sentBy, String recipientId, String message);
  Future<void> sendImageMessage(String chatId, String sentBy, String recipientId, File imageFile);
  Future<void> sendDocumentMessage(String chatId, String sentBy, String recipientId, File docFile);
  Future<void> sendSystemMessage(String chatId, String sentBy, String recipientId, String message, String type, String referenceId);
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage firebaseStorage;

  MessageRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseStorage,
  });

  // This is already optimal, no changes needed.
  @override
  Stream<List<MessagesModel>> getChatMessages(String docId) {
    return firestore
        .collection('chats')
        .doc(docId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MessagesModel.fromFirestore(doc)).toList());
  }

  // --- REFACTORED AND OPTIMIZED SEND METHODS ---

  @override
  Future<void> sendTextMessage(String chatId, String sentBy, String recipientId, String message) async {
    final messageData = {
      'storagePath': '',
      'message': message,
      'type': 'text',
    };
    final lastMessageData = {
      'lastMessage': message,
      'lastMessageType': 'text',
    };
    await _sendMessage(chatId, sentBy, recipientId, messageData, lastMessageData);
  }

  @override
  Future<void> sendImageMessage(String chatId, String sentBy, String recipientId, File imageFile) async {
    final uploadUrl = await _uploadFile(imageFile, 'Chats/Images/');
    final messageData = {
      'storagePath': uploadUrl,
      'message': '', // Or a caption if you have one
      'type': 'image',
    };
    final lastMessageData = {
      'lastMessage': '📷 Photo',
      'lastMessageType': 'image',
    };
    await _sendMessage(chatId, sentBy, recipientId, messageData, lastMessageData);
  }

  @override
  Future<void> sendDocumentMessage(String chatId, String sentBy, String recipientId, File docFile) async {
    final uploadUrl = await _uploadFile(docFile, 'Chats/Files/');
    final messageData = {
      'storagePath': uploadUrl,
      'message': path.basename(docFile.path), // Use the file name as the message
      'type': 'file',
    };
    final lastMessageData = {
      'lastMessage': '📄 Document',
      'lastMessageType': 'file',
    };
    await _sendMessage(chatId, sentBy, recipientId, messageData, lastMessageData);
  }

  // --- PRIVATE HELPER METHODS ---

  /// Private helper to upload a file to Firebase Storage and return the URL.
  // Future<String> _uploadFile(File file, String storagePath) async {
  //   try {
  //     final fileExtension = path.extension(file.path);
  //     final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
  //     final storageRef = firebaseStorage.ref().child('$storagePath$fileName');
  //     await storageRef.putFile(file);
  //     return await storageRef.getDownloadURL();
  //   } on FirebaseException catch (e) {
  //     throw ServerException('File upload failed: ${e.message}');
  //   }
  // }

  Future<String> _uploadFile(File file, String storagePathPrefix) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final fullStoragePath = '$storagePathPrefix$fileName'; // e.g., "Chats/Images/12345.jpg"
      final storageRef = firebaseStorage.ref().child(fullStoragePath);
      await storageRef.putFile(file);
      return fullStoragePath; // <-- RETURN THE PATH
    } on FirebaseException catch (e) {
      throw ServerException('File upload failed: ${e.message}');
    }
  }



  @override
  Future<void> sendSystemMessage(String chatId, String sentBy, String recipientId, String message, String type, String referenceId) async  {
    final messageData = {
      'storagePath': '',
      'message': message,
      'type': type,
      'referenceId': referenceId, // <-- PASS IT HERE
    };
    final lastMessageData = {
      'lastMessage': '📎 Gate Pass Request',
      'lastMessageType': type,
    };
    await _sendMessage(chatId, sentBy, recipientId, messageData, lastMessageData);
  }



  /// The single, optimized method for sending any message.
  Future<void> _sendMessage(
      String chatId,
      String sentBy,
      String recipientId,
      Map<String, dynamic> messageData,
      Map<String, dynamic> lastMessageData,
      ) async {
    try {
      final messageModel = MessagesModel(
        messageId: '', // Will be generated by Firestore
          storagePath: messageData['storagePath'],
        message: messageData['message'],
        sentBy: sentBy,
        status: 'sent',
        type: messageData['type'],
        timestamp: DateTime.now(),// Will be replaced by server timestamp
        referenceId: messageData['referenceId']
      );

      final chatDocRef = firestore.collection('chats').doc(chatId);
      final messageRef = chatDocRef.collection('messages').doc();

      final batch = firestore.batch();

      // 1. Add the new message to the subcollection
      batch.set(messageRef, messageModel.toJson());

      // 2. Update the last message details on the main chat document
      batch.update(chatDocRef, {
        ...lastMessageData,
        'lastMessageSenderId': sentBy,
        'lastMessageTimestamp': FieldValue.serverTimestamp(), // Use server time for accuracy
      });

      // 3. ATOMICALLY increment the unread count for the recipient.
      // This is the key optimization. No read is required.
      batch.update(chatDocRef, {
        'unreadCounts.$recipientId': FieldValue.increment(1),
      });

      // Commit all three operations at once.
      await batch.commit();
    } on FirebaseException catch (e) {
      log("Error sending message: $e");
      throw ServerException(e.message ?? 'Failed to send message.');
    } catch (e) {
      log("Unexpected error sending message: $e");
      throw ServerException('An unexpected error occurred.');
    }
  }

}