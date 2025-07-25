part of 'chat_details_bloc.dart';

sealed class ChatDetailsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckOrCreateChatEvent extends ChatDetailsEvent {
  final ChatUserEntity user;
  final ChatUserEntity targetUser;
  final bool isMatched;

  CheckOrCreateChatEvent({required this.user, required this.targetUser, required this.isMatched});

  @override
  List<Object?> get props => [user, targetUser,isMatched];
}


