part of 'messages_bloc.dart';

sealed class MessagesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetMessagesEvent extends MessagesEvent {
  final String chatId;

   GetMessagesEvent({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}