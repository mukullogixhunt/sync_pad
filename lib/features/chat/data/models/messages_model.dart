import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/messages_entity.dart';

class MessagesModel extends MessagesEntity {
  MessagesModel({
    required super.messageId,
    required super.url,
    required super.message,
    required super.sentBy,
    required super.status,
    required super.type,
    required super.timestamp,
    super.referenceId, // <-- ADD THIS

  });

  // factory MessagesModel.fromFirestore(DocumentSnapshot doc) {
  //   return MessagesModel(
  //     messageId: doc.id,
  //     url: doc['url'],
  //     message: doc['message'],
  //     sentBy: doc['sentBy'],
  //     status: doc['status'],
  //     type: doc['type'],
  //     timestamp: (doc['timestamp'] as Timestamp).toDate(),
  //   );
  // }


  factory MessagesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Safer cast
    return MessagesModel(
      messageId: doc.id,
      url: data['url'] ?? '',
      message: data['message'] ?? '',
      sentBy: data['sentBy'] ?? '',
      status: data['status'] ?? 'sent',
      type: data['type'] ?? 'text',
      timestamp: (data['timestamp'] as Timestamp? ?? Timestamp.now()).toDate(),
      referenceId: data['referenceId'], // <-- ADD THIS
    );
  }

  factory MessagesModel.fromEntity(MessagesEntity entity) {
    return MessagesModel(
      messageId: entity.messageId,
      url: entity.url,
      message: entity.message,
      sentBy: entity.sentBy,
      status: entity.status,
      type: entity.type,
      timestamp: entity.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': messageId,
      'url': url,
      'message': message,
      'sentBy': sentBy,
      'status': status,
      'type': type,
      'timestamp': timestamp,
      'referenceId': referenceId, // <-- ADD THIS
    };
  }

  MessagesModel copyWith({
    String? messageId,
    String? url,
    String? message,
    String? sentBy,
    String? status,
    String? type,
    DateTime? timestamp,
    String? referenceId,
  }) {
    return MessagesModel(
      messageId: messageId ?? this.messageId,
      url: url ?? this.url,
      message: message ?? this.message,
      sentBy: sentBy ?? this.sentBy,
      status: status ?? this.status,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      referenceId: referenceId ?? this.referenceId,
    );
  }

}
