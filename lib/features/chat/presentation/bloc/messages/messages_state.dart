part of 'messages_bloc.dart';

sealed class MessagesState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<MessagesEntity> messages;

  MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessagesFailure extends MessagesState {
  final String message;

  MessagesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
