import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chats_entity.dart';
import '../repositories/chats_repository.dart';

class CheckOrCreateChatUseCase {
  final ChatRepository repository;

  CheckOrCreateChatUseCase({required this.repository});

  Future<Either<Failure, ChatsEntity?>> call(ChatUserEntity user, ChatUserEntity targetUser,bool isMatched) {
    return repository.checkOrCreateChat(user, targetUser,isMatched);
  }
}
