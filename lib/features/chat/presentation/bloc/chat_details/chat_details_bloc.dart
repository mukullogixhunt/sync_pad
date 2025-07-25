import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/chats_entity.dart';
import '../../../domain/usecases/check_create_chat_use_case.dart';


part 'chat_details_event.dart';
part 'chat_details_state.dart';

class ChatDetailsBloc extends Bloc<ChatDetailsEvent, ChatDetailsState> {
  final CheckOrCreateChatUseCase checkOrCreateChat;

  ChatDetailsBloc({required this.checkOrCreateChat})
      : super(ChatsInitial()) {
    on<ChatDetailsEvent>((event, emit) {});
    on<CheckOrCreateChatEvent>(_onCheckOrCreateChat);
  }

  Future<void> _onCheckOrCreateChat(
      CheckOrCreateChatEvent event, Emitter<ChatDetailsState> emit) async {
    emit(ChatDetailsLoading());
    final result = await checkOrCreateChat(event.user, event.targetUser,event.isMatched);

    result.fold(
      (failure) =>
          emit(ChatDetailsFailure(failure.message ?? 'An error occurred')),
      (chat) => emit(ChatDetailsLoaded(chat!)),
    );
  }


}



