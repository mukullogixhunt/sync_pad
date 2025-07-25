import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chats_entity.dart';
import '../repositories/chats_repository.dart';

class GetChatsForUserUseCase {
  final ChatRepository repository;

  GetChatsForUserUseCase({required this.repository});

  Stream<Either<Failure, List<ChatsEntity>>> call(String userId) {
    return repository.getChatsForUser(userId);
  }
}
