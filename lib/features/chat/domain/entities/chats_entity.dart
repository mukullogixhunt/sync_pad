
class ChatsEntity {
  final String chatId;
  final String lastMessage;
  final String lastMessageType;
  final String lastMessageSenderId;
  final String chatStatus;
  final DateTime lastMessageTimestamp;
  final bool isMatched;
  final List<ChatUserEntity> participants;
  final List<String> participantIds;


  ChatsEntity({
    required this.chatId,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageSenderId,
    required this.chatStatus,
    required this.lastMessageTimestamp,
    required this.isMatched,
    required this.participants,
    required this.participantIds,
  });
}

class ChatUserEntity {
  final String userId;
  final String name;
  final String email;
  final int unreadCount;
  final String profilePicture;
  final DateTime lastOnline;

  ChatUserEntity({
    required this.userId,
    required this.name,
    required this.email,
    required this.unreadCount,
    required this.profilePicture,
    required this.lastOnline,
  });
}
