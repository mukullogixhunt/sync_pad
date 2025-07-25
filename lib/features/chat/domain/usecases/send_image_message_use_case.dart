import 'dart:io';

import 'package:dartz/dartz.dart';


import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/message_repository.dart';

class SendImageMessageUseCase implements UseCase<void, SendImageParams>{
  final MessageRepository repository;

  SendImageMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SendImageParams params) {
    return repository.sendImageMessage(params.chatId,params.sentBy,params.recipientId,params.imageFile);
  }
}

class SendImageParams {
  final String chatId; final String sentBy;final String recipientId; final File imageFile;

  SendImageParams({
    required this.chatId,
    required this.sentBy,
    required this.recipientId,
    required this.imageFile,
  });
}
