import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/usecases/read_messages_use_case.dart';

part 'read_message_event.dart';
part 'read_message_state.dart';

class ReadMessageBloc extends Bloc<ReadMessageEvent, ReadMessageState> {
  final ReadMessagesUseCase readMessagesUseCase;

  ReadMessageBloc({required this.readMessagesUseCase})
      : super(ReadMessageInitial()) {
    on<ReadMessageEvent>((event, emit) {});
    on<ReadTextMessageEvent>(_onSendTextMessage);
  }

  Future<void> _onSendTextMessage(
      ReadTextMessageEvent event, Emitter<ReadMessageState> emit) async {
    emit(ReadingMessage());
    final result = await readMessagesUseCase(
        ReadMessageParams(chatId: event.chatId, userId: event.userId));

    result.fold(
      (failure) =>
          emit(ReadMessageFailure(failure.message ?? 'An error occurred')),
      (_) => emit(MessageRead()),
    );
  }
}
