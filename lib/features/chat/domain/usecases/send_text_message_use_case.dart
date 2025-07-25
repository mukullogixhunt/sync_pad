import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/chats_entity.dart';
import '../repositories/chats_repository.dart';
import '../repositories/message_repository.dart';

class SendTextMessageUseCase implements UseCase<void, SendTextParams>{
  final MessageRepository repository;

  SendTextMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SendTextParams params) {
    return repository.sendTextMessage(params.chatId,params.sentBy,params.recipientId,params.message);
  }
}

class SendTextParams {
  final String chatId; final String sentBy;final String recipientId; final String message;

  SendTextParams({
    required this.chatId,
    required this.sentBy,
    required this.recipientId,
    required this.message,
  });
}
