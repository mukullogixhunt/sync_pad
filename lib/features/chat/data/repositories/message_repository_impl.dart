import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/messages_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_remote_data_source.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource remoteDataSource;

  MessageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendTextMessage(
    String chatId,
    String sentBy,
    String recipientId,
    String message,
  ) async {
    try {
      final response = await remoteDataSource.sendTextMessage(
        chatId,
        sentBy,
        recipientId,

        message,
      );

      return Right(response);
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> sendImageMessage(
    String chatId,
    String sentBy,
    String recipientId,
    File imageFile,
  ) async {
    try {
      final response = await remoteDataSource.sendImageMessage(
        chatId,
        sentBy,
        recipientId,

        imageFile,
      );

      return Right(response);
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }

  @override
  Stream<Either<Failure, List<MessagesEntity>>> getChatMessages(
    String userId,
  ) async* {
    try {
      yield* remoteDataSource
          .getChatMessages(userId)
          .map((messages) => Right<Failure, List<MessagesEntity>>(messages));
    } catch (e) {
      yield const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> sendDocumentMessage(
    String chatId,
    String sentBy,
    String recipientId,
    File documentFile,
  ) async {
    try {
      final response = await remoteDataSource.sendDocumentMessage(
        chatId,
        sentBy,
        recipientId,
        documentFile,
      );

      return Right(response);
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> sendSystemMessage(
    String chatId,
    String sentBy,
    String recipientId,
    String message,
    String type,
    String referenceId,
  ) async {
    try {
      final response = await remoteDataSource.sendSystemMessage(
        chatId,
        sentBy,
        recipientId,
        message,
        type,
        referenceId,
      );

      return Right(response);
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }
}
