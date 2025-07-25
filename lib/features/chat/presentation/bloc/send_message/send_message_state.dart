part of 'send_message_bloc.dart';

sealed class SendMessageState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class SendMessageInitial extends SendMessageState {}

class SendingMessage extends SendMessageState {}

class MessageSent extends SendMessageState {}

class SendMessageFailure extends SendMessageState {
  final String message;

  SendMessageFailure(this.message);

  @override
  List<Object?> get props => [message];
}
