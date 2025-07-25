import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';


import '../../../../core/usecase/usecase.dart';
import '../repositories/chats_repository.dart';
import '../repositories/message_repository.dart';

class ReadMessagesUseCase implements UseCase<void, ReadMessageParams>{
  final ChatRepository repository;

  ReadMessagesUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(ReadMessageParams params) {
    return repository.markMessagesAsRead(params.chatId,params.userId);
  }
}

class ReadMessageParams {
  final String chatId; final String userId;

  ReadMessageParams({
    required this.chatId,
    required this.userId,

  });
}
