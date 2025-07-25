part of 'read_message_bloc.dart';

sealed class ReadMessageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReadTextMessageEvent extends ReadMessageEvent {
  final String chatId;
  final String userId;

  ReadTextMessageEvent({
    required this.chatId,
    required this.userId,
  });

  @override
  List<Object?> get props => [chatId,userId];
}

