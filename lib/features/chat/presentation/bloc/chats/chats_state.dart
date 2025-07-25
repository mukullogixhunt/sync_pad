part of 'chats_bloc.dart';

sealed class ChatsState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ChatsInitial extends ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsLoaded extends ChatsState {
  final List<ChatsEntity> chats;

  ChatsLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatsFailure extends ChatsState {
  final String message;

  ChatsFailure(this.message);

  @override
  List<Object?> get props => [message];
}


