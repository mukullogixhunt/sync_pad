import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/features/chat/domain/usecases/send_document_message_use_case.dart';
import 'package:sync_pad/features/chat/domain/usecases/send_system_message_use_case.dart';

import '../../../domain/usecases/send_image_message_use_case.dart';
import '../../../domain/usecases/send_text_message_use_case.dart';

part 'send_message_event.dart';
part 'send_message_state.dart';

class SendMessageBloc extends Bloc<SendMessageEvent, SendMessageState> {
  final SendTextMessageUseCase sendTextMessageUseCase;
  final SendImageMessageUseCase sendImageMessageUseCase;
  final SendDocumentMessageUseCase sendDocumentMessageUseCase;
  final SendSystemMessageUseCase sendSystemMessageUseCase;

  SendMessageBloc({
    required this.sendTextMessageUseCase,
    required this.sendImageMessageUseCase,
    required this.sendDocumentMessageUseCase,
    required this.sendSystemMessageUseCase,
  }) : super(SendMessageInitial()) {
    on<SendMessageEvent>((event, emit) {});
    on<SendTextMessageEvent>(_onSendTextMessage);
    on<SendImageMessageEvent>(_onSendImageMessage);
    on<SendDocumentMessageEvent>(_onSendDocumentMessage);
    on<SendSystemMessageEvent>(_onSendSystemMessageEvent);
  }

  Future<void> _onSendTextMessage(
    SendTextMessageEvent event,
    Emitter<SendMessageState> emit,
  ) async {
    emit(SendingMessage());
    final result = await sendTextMessageUseCase(
      SendTextParams(
        chatId: event.chatId,
        sentBy: event.sentBy,
        recipientId: event.recipientId,
        message: event.message,
      ),
    );

    result.fold(
      (failure) =>
          emit(SendMessageFailure(failure.message ?? 'An error occurred')),
      (_) => emit(MessageSent()),
    );
  }

  Future<void> _onSendImageMessage(
    SendImageMessageEvent event,
    Emitter<SendMessageState> emit,
  ) async {
    emit(SendingMessage());
    final result = await sendImageMessageUseCase(
      SendImageParams(
        chatId: event.chatId,
        sentBy: event.sentBy,
        recipientId: event.recipientId,
        imageFile: event.imageFile,
      ),
    );

    result.fold(
      (failure) =>
          emit(SendMessageFailure(failure.message ?? 'An error occurred')),
      (_) => emit(MessageSent()),
    );
  }

  Future<void> _onSendDocumentMessage(
    SendDocumentMessageEvent event,
    Emitter<SendMessageState> emit,
  ) async {
    emit(SendingMessage());
    final result = await sendDocumentMessageUseCase(
      SendDocumentParams(
        chatId: event.chatId,
        sentBy: event.sentBy,
        recipientId: event.recipientId,
        docFile: event.docFile,
      ),
    );

    result.fold(
      (failure) =>
          emit(SendMessageFailure(failure.message ?? 'An error occurred')),
      (_) => emit(MessageSent()),
    );
  }

  FutureOr<void> _onSendSystemMessageEvent(
    SendSystemMessageEvent event,
    Emitter<SendMessageState> emit,
  ) async {
    emit(SendingMessage());
    final result = await sendSystemMessageUseCase(
      SendSystemParams(
        chatId: event.chatId,
        sentBy: event.sentBy,
        recipientId: event.recipientId,
        message: event.message,
        type: event.type,
        referenceId: event.referenceId,
      ),
    );

    result.fold(
      (failure) =>
          emit(SendMessageFailure(failure.message ?? 'An error occurred')),
      (_) => emit(MessageSent()),
    );
  }
}
