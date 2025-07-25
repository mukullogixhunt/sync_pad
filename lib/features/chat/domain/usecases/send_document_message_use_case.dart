import 'dart:io';

import 'package:dartz/dartz.dart';


import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/message_repository.dart';

class SendDocumentMessageUseCase implements UseCase<void, SendDocumentParams>{
  final MessageRepository repository;

  SendDocumentMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SendDocumentParams params) {
    return repository.sendDocumentMessage(params.chatId,params.sentBy,params.recipientId,params.docFile);
  }
}

class SendDocumentParams {
  final String chatId; final String sentBy;final String recipientId; final File docFile;

  SendDocumentParams({
    required this.chatId,
    required this.sentBy,
    required this.recipientId,
    required this.docFile,
  });
}
