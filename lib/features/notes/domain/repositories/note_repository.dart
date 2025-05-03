import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/features/notes/domain/entities/note_entity.dart';

abstract class NoteRepository {
  Future<Either<Failure, List<NoteEntity>>> getNotes();

  Future<Either<Failure, NoteEntity>> saveNote(NoteEntity note);

  Future<Either<Failure, void>> deleteNote(String id);

  Future<Either<Failure, void>> syncNotes();

  Future<Either<Failure, List<NoteEntity>>> refreshNotesFromRemote();
}
