import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/chats_entity.dart';
import '../../domain/repositories/chats_repository.dart';
import '../datasources/chats_remote_data_source.dart';
import '../models/chats_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChatsEntity?>> checkOrCreateChat(
    ChatUserEntity user,
    ChatUserEntity targetUser,
    bool isMatched,
  ) async {
    try {
      // Convert user and targetUser to ChatUserModels for lookup
      final userModel = ChatUserModel.fromEntity(user);
      final targetUserModel = ChatUserModel.fromEntity(targetUser);

      final existingChat = await remoteDataSource.checkOrCreateChat(
        userModel,
        targetUserModel,
        isMatched,
      );

      return Right(existingChat);
    } catch (e) {
      return const Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Stream<Either<Failure, List<ChatsEntity>>> getChatsForUser(
    String userId,
  ) async* {
    try {
      yield* remoteDataSource
          .getChatsForUser(userId)
          .map((chats) => Right<Failure, List<ChatsEntity>>(chats));
    } catch (e) {
      yield const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(
    String chatDocumentId,
    String chatUserId,
  ) async {
    try {
      // Convert user and targetUser to ChatUserModels for lookup

      final existingChat = await remoteDataSource.markMessagesAsRead(
        chatDocumentId,
        chatUserId,
      );

      return Right(existingChat);
    } catch (e) {
      return const Left(ServerFailure('Unexpected error occurred'));
    }
  }
}
