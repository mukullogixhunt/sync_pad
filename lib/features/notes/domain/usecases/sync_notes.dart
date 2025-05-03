import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/notes/domain/repositories/note_repository.dart';

class SyncNotes implements UseCase<void, NoParams> {
  final NoteRepository repository;

  SyncNotes({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.syncNotes();
  }
}
