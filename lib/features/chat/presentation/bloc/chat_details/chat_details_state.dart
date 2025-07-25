part of 'chat_details_bloc.dart';

sealed class ChatDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ChatsInitial extends ChatDetailsState {}

class ChatDetailsLoading extends ChatDetailsState {}

class ChatDetailsLoaded extends ChatDetailsState {
  final ChatsEntity chat;

  ChatDetailsLoaded(this.chat);

  @override
  List<Object?> get props => [chat];
}

class ChatDetailsFailure extends ChatDetailsState {
  final String message;

  ChatDetailsFailure(this.message);

  @override
  List<Object?> get props => [message];
}




