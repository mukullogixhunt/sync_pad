import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chats_entity.dart';
import '../entities/messages_entity.dart';
import '../repositories/chats_repository.dart';
import '../repositories/message_repository.dart';

class GetMessagesUseCase {
  final MessageRepository repository;

  GetMessagesUseCase({required this.repository});

  Stream<Either<Failure, List<MessagesEntity>>> call(String docId) {
    return repository.getChatMessages(docId);
  }
}
