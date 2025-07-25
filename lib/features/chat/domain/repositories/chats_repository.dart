import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/chats_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatsEntity?>> checkOrCreateChat(
    ChatUserEntity user,
    ChatUserEntity targetUser,
    bool isMatched,
  );

  Stream<Either<Failure, List<ChatsEntity>>> getChatsForUser(String userId);

  Future<Either<Failure, void>> markMessagesAsRead(
    String chatDocumentId,
    String chatUserId,
  );
}
