import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/messages_entity.dart';
import '../../../domain/usecases/get_messages_use_case.dart';


part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final GetMessagesUseCase getMessagesUseCase;

  MessagesBloc({required this.getMessagesUseCase}) : super(MessagesInitial()) {
    on<MessagesEvent>((event, emit) {});
    on<GetMessagesEvent>(_onGetMessages);
  }

  Future<void> _onGetMessages(
      GetMessagesEvent event, Emitter<MessagesState> emit) async {
    emit(MessagesLoading());
    await emit.forEach<Either<Failure, List<MessagesEntity>>>(
      getMessagesUseCase(event.chatId),
      onData: (result) {
        return result.fold(
          (failure) {
            return MessagesFailure(failure.message ?? 'An error occurred');
          },
          (messages) => MessagesLoaded(messages),
        );
      },
      onError: (error, stackTrace) {
        return MessagesFailure('Failed to load chats.');
      },
    );
  }
}
