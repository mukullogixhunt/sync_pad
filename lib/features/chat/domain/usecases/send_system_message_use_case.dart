import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/message_repository.dart';

class SendSystemMessageUseCase implements UseCase<void, SendSystemParams> {
  final MessageRepository repository;

  SendSystemMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SendSystemParams params) {
    return repository.sendSystemMessage(
      params.chatId,
      params.sentBy,
      params.recipientId,
      params.message,
      params.type,
      params.referenceId,
    );
  }
}

class SendSystemParams {
  final String chatId;
  final String sentBy;
  final String recipientId;
  final String message;
  final String type;
  final String referenceId;

  SendSystemParams({
    required this.chatId,
    required this.sentBy,
    required this.recipientId,
    required this.message,
    required this.type,
    required this.referenceId,
  });
}
