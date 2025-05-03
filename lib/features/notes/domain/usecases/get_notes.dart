import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/notes/domain/entities/note_entity.dart';
import 'package:sync_pad/features/notes/domain/repositories/note_repository.dart';

class GetNotes implements UseCase<List<NoteEntity>, NoParams> {
  final NoteRepository repository;

  GetNotes({required this.repository});

  @override
  Future<Either<Failure, List<NoteEntity>>> call(NoParams params) async {
    return await repository.getNotes();
  }
}