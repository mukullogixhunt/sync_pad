part of 'send_message_bloc.dart';

sealed class SendMessageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendTextMessageEvent extends SendMessageEvent {
  final String chatId;
  final String sentBy;
  final String recipientId;
  final String message;

  SendTextMessageEvent({
    required this.chatId,
    required this.sentBy,
    required this.recipientId,
    required this.message,
  });

  @override
  List<Object?> get props => [chatId,sentBy,recipientId,message];
}

class SendImageMessageEvent extends SendMessageEvent {
  final String chatId;
  final String sentBy;
  final String recipientId;
  final File imageFile;

  SendImageMessageEvent({
    required this.chatId,
    required this.sentBy,
    required this.recipientId,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [chatId,sentBy,recipientId,imageFile];
}


class SendDocumentMessageEvent extends SendMessageEvent {
  final String chatId;
  final String sentBy;
  final String recipientId;
  final File docFile;

  SendDocumentMessageEvent({
    required this.chatId,
    required this.sentBy,
    required this.recipientId,
    required this.docFile,
  });

  @override
  List<Object?> get props => [chatId,sentBy,recipientId,docFile];
}


class SendSystemMessageEvent extends SendMessageEvent {
  final String chatId;
  final String sentBy;
  final String recipientId;
  final String message;
  final String type;
  final String referenceId;

  SendSystemMessageEvent({
    required this.chatId,
    required this.sentBy,
    required this.recipientId,
    required this.message,
    required this.type,
    required this.referenceId,
  });

  @override
  List<Object?> get props => [chatId,sentBy,recipientId,message,type,referenceId];
}

class SendAudioMessageEvent extends SendMessageEvent {
  final String chatId;
  final String sentBy;
  final String recipientId;
  final File audioFile;

  SendAudioMessageEvent({
    required this.chatId,
    required this.sentBy,
    required this.recipientId,
    required this.audioFile,
  });

  @override
  List<Object?> get props => [chatId, sentBy,recipientId, audioFile];
}