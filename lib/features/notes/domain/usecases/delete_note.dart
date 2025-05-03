
import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/notes/domain/repositories/note_repository.dart';
import 'package:equatable/equatable.dart';

class DeleteNote implements UseCase<void, DeleteNoteParams> {
  final NoteRepository repository;

  DeleteNote({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) async {
    if (params.id.trim().isEmpty) {
      return Left(UnexpectedFailure("Note ID cannot be empty."));
    }
    return await repository.deleteNote(params.id);
  }
}

class DeleteNoteParams extends Equatable {
  final String id;

  const DeleteNoteParams({required this.id});

  @override
  List<Object?> get props => [id];
}