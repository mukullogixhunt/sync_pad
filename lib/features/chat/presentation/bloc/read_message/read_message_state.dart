part of 'read_message_bloc.dart';

sealed class ReadMessageState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ReadMessageInitial extends ReadMessageState {}

class ReadingMessage extends ReadMessageState {}

class MessageRead extends ReadMessageState {}

class ReadMessageFailure extends ReadMessageState {
  final String message;

  ReadMessageFailure(this.message);

  @override
  List<Object?> get props => [message];
}
