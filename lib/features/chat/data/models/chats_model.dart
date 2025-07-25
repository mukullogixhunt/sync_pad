import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chats_entity.dart';

class ChatsModel extends ChatsEntity {
  ChatsModel({
    required super.chatId,
    required super.lastMessage,
    required super.lastMessageType,
    required super.lastMessageSenderId,
    required super.chatStatus,
    required super.lastMessageTimestamp,
    required super.isMatched,
    required super.participants,
    required super.participantIds,
  });

  factory ChatsModel.fromFirestore(DocumentSnapshot doc) {
    var participants =
        (doc['participants'] as List)
            .map((cat) => ChatUserModel.fromJson(cat))
            .toList();

    return ChatsModel(
      chatId: doc.id,
      lastMessage: doc['lastMessage'],
      lastMessageType: doc['lastMessageType'],
      lastMessageSenderId: doc['lastMessageSenderId'],
      chatStatus: doc['chatStatus'],
      isMatched: doc['isMatched'],
      lastMessageTimestamp: (doc['lastMessageTimestamp'] as Timestamp).toDate(),
      participants: participants,
      participantIds: List<String>.from(doc['participantIds'] ?? []),
    );
  }

  factory ChatsModel.fromEntity(ChatsEntity entity) {
    return ChatsModel(
      chatId: entity.chatId,
      lastMessage: entity.lastMessage,
      lastMessageType: entity.lastMessageType,
      lastMessageSenderId: entity.lastMessageSenderId,
      chatStatus: entity.chatStatus,
      isMatched: entity.isMatched,
      lastMessageTimestamp: entity.lastMessageTimestamp,
      participants: entity.participants,
      participantIds: entity.participantIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'chatStatus': chatStatus,
      'isMatched': isMatched,
      'lastMessageTimestamp': lastMessageTimestamp,
      'lastMessageSenderId': lastMessageSenderId,
      'participants':
          participants
              .map((participant) => (participant as ChatUserModel).toJson())
              .toList(),
      'participantIds': participants.map((p) => p.userId).toList(),
    };
  }

  // CopyWith method
  ChatsModel copyWith({
    String? chatId,
    String? lastMessage,
    String? lastMessageType,
    String? lastMessageSenderId,
    String? chatStatus,
    bool? isMatched,
    DateTime? lastMessageTimestamp,
    List<ChatUserModel>? participants,
    List<String>? participantIds,
  }) {
    return ChatsModel(
      chatId: chatId ?? this.chatId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      chatStatus: chatStatus ?? this.chatStatus,
      isMatched: isMatched ?? this.isMatched,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      participants: participants ?? this.participants,
      participantIds: participantIds ?? this.participantIds,
    );
  }
}

class ChatUserModel extends ChatUserEntity {
  ChatUserModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.unreadCount,
    required super.profilePicture,
    required super.lastOnline,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      unreadCount: json['unreadCount'],
      profilePicture: json['profilePicture'],
      lastOnline: (json['lastOnline'] as Timestamp).toDate(),
    );
  }

  factory ChatUserModel.fromEntity(ChatUserEntity entity) {
    return ChatUserModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      unreadCount: entity.unreadCount,
      profilePicture: entity.profilePicture,
      lastOnline: entity.lastOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'unreadCount': unreadCount,
      'profilePicture': profilePicture,
      'lastOnline': lastOnline,
    };
  }

  ChatUserModel copyWith({
    String? userId,
    String? name,
    String? email,
    int? unreadCount,
    String? profilePicture,
    DateTime? lastOnline,
  }) {
    return ChatUserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      unreadCount: unreadCount ?? this.unreadCount,
      profilePicture: profilePicture ?? this.profilePicture,
      lastOnline: lastOnline ?? this.lastOnline,
    );
  }
}
