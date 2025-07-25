part of 'chats_bloc.dart';

sealed class ChatsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}



class GetChatsForUserEvent extends ChatsEvent {
  final String userId;

  GetChatsForUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}


