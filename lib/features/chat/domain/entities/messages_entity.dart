class MessagesEntity {
  final String messageId;
  final String url;
  final String message;
  final String sentBy;
  final String status;
  final String type;
  final DateTime timestamp;
  final String? referenceId;


  MessagesEntity({
    required this.messageId,
    required this.url,
    required this.message,
    required this.sentBy,
    required this.status,
    required this.type,
    required this.timestamp,
    this.referenceId, // <-- ADD THIS
  });
}
