


import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_pad/core/error/exceptions.dart';
import '../models/chats_model.dart'; // Ensure your model is imported

abstract class ChatRemoteDataSource {
  Future<ChatsModel> checkOrCreateChat(ChatUserModel user, ChatUserModel targetUser, bool isMatched);
  Stream<List<ChatsModel>> getChatsForUser(String userId);
  Future<void> markMessagesAsRead(String chatDocumentId, String chatUserId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  // --- OPTIMIZED getChatsForUser ---
  @override
  Stream<List<ChatsModel>> getChatsForUser(String userId) {
    // This query is now highly efficient. It only fetches documents where the
    // user is a participant. The sorting is also done on the server.
    return firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true) // This will require an index
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatsModel.fromFirestore(doc)).toList();
    }).handleError((error) {
      log('Error getting chats for user: $error');
      // Propagate the error through the stream
      throw ServerException('Failed to get chats.');
    });
  }

  // --- OPTIMIZED checkOrCreateChat ---
  @override
  Future<ChatsModel> checkOrCreateChat(ChatUserModel user, ChatUserModel targetUser, bool isMatched) async {
    try {
      // To create a predictable chat ID and avoid race conditions
      final ids = [user.userId, targetUser.userId]..sort();
      final chatDocumentId = ids.join('_');

      final chatDocRef = firestore.collection('chats').doc(chatDocumentId);
      final chatDoc = await chatDocRef.get();

      // If the chat already exists, return it
      if (chatDoc.exists) {
        return ChatsModel.fromFirestore(chatDoc);
      }

      // If no existing chat found, create a new one with the predictable ID
      final newChat = ChatsModel(
        chatId: chatDocumentId,
        lastMessage: 'Tap to start a conversation',
        lastMessageType: 'text',
        chatStatus: 'Active',
        lastMessageTimestamp: DateTime.now(),
        lastMessageSenderId: "",
        participants: [user, targetUser],
        participantIds: [user.userId, targetUser.userId], // Include the new field
        isMatched: isMatched,
      );

      await chatDocRef.set(newChat.toJson());
      return newChat;

    } on FirebaseException catch (e) {
      log('Firebase error in checkOrCreateChat: $e');
      throw ServerException(e.message ?? 'An error occurred.');
    } catch (e) {
      log('Unexpected error in checkOrCreateChat: $e');
      throw ServerException('An unexpected error occurred.');
    }
  }

  // --- markMessagesAsRead (no changes needed, it's already efficient) ---
  @override
  Future<void> markMessagesAsRead(String chatDocumentId, String chatUserId) async {
    try {
      final chatDocRef = firestore.collection('chats').doc(chatDocumentId);
      final chatDoc = await chatDocRef.get();
      if (!chatDoc.exists) {
        throw ServerException('Chat document does not exist.');
      }
      List<dynamic> participants = chatDoc['participants'];
      participants = participants.map((participant) {
        if (participant['userId'] == chatUserId) {
          return {...participant, 'unreadCount': 0};
        }
        return participant;
      }).toList();
      await chatDocRef.update({'participants': participants});
    } on FirebaseException catch (e) {
      throw ServerException('Firebase error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
