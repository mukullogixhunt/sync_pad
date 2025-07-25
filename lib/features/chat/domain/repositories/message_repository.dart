import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/messages_entity.dart';

abstract class MessageRepository {
  Future<Either<Failure, void>> sendTextMessage(
    String chatId,
    String sentBy,
    String recipientId,
    String message,
  );

  Future<Either<Failure, void>> sendImageMessage(
    String chatId,
    String sentBy,
    String recipientId,
    File imageFile,
  );

  Future<Either<Failure, void>> sendDocumentMessage(
    String chatId,
    String sentBy,
    String recipientId,
    File documentFile,
  );

  Future<Either<Failure, void>> sendSystemMessage(
    String chatId,
    String sentBy,
    String recipientId,
    String message,
    String type,
    String referenceId,
  );

  Stream<Either<Failure, List<MessagesEntity>>> getChatMessages(String docId);
}
