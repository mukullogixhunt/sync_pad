import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/notes/domain/entities/note_entity.dart';
import 'package:sync_pad/features/notes/domain/repositories/note_repository.dart';
import 'package:equatable/equatable.dart';

class SaveNote implements UseCase<NoteEntity, SaveNoteParams> {
  final NoteRepository repository;

  SaveNote({required this.repository});

  @override
  Future<Either<Failure, NoteEntity>> call(SaveNoteParams params) async {
    if (params.note.title.trim().isEmpty) {
      return Left(UnexpectedFailure("Title cannot be empty."));
    }

    return await repository.saveNote(params.note);
  }
}

// Use entity directly as params for simplicity now
class SaveNoteParams extends Equatable {
  final NoteEntity note;

  const SaveNoteParams({required this.note});

  @override
  List<Object?> get props => [note];
}

// Alternative Params if creating new:
// class CreateNoteParams extends Equatable {
//   final String title;
//   final String content;
//   const CreateNoteParams({required this.title, required this.content});
//   @override List<Object?> get props => [title, content];
// }
