import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/exceptions.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/network/connectivity_service.dart';
import 'package:sync_pad/features/notes/data/datasources/local/local_note_datasource.dart';
import 'package:sync_pad/features/notes/data/datasources/remote/remote_note_datasource.dart';
import 'package:sync_pad/features/notes/data/models/note_model.dart';
import 'package:sync_pad/features/notes/domain/entities/note_entity.dart';
import 'package:sync_pad/features/notes/domain/repositories/note_repository.dart';
import 'dart:developer';

class NoteRepositoryImpl implements NoteRepository {
  final LocalNoteDataSource localDataSource;
  final RemoteNoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  NoteRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<NoteEntity>>> getNotes() async {
    log("[Repository] Getting notes from local data source...");
    try {
      final List<NoteModel> localNotes = await localDataSource.getAllNotes();

      log(
        "[Repository] Successfully fetched ${localNotes.length} notes locally.",
      );
      return Right(localNotes);
    } on CacheException catch (e) {
      log("[Repository] CacheException getting notes: ${e.message}");
      return Left(CacheFailure(e.message));
    } catch (e) {
      log("[Repository] Unexpected error getting notes: $e");
      return Left(UnexpectedFailure("Failed to get notes: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, NoteEntity>> saveNote(NoteEntity noteEntity) async {
    log("[Repository] Saving note (ID: ${noteEntity.id})...");
    try {
      NoteModel noteToSave;

      final existingModel = await localDataSource.getNoteById(noteEntity.id);

      if (existingModel != null) {
        log("[Repository] Updating existing note locally.");

        noteToSave = existingModel.copyWith(
          title: noteEntity.title,
          content: noteEntity.content,
        );
      } else {
        log("[Repository] Creating new note locally.");

        noteToSave = NoteModel.fromEntity(noteEntity);
      }

      await localDataSource.saveNote(noteToSave);
      log(
        "[Repository] Saved note locally (isSynced: ${noteToSave.isSynced}).",
      );

      return Right(noteToSave);
    } on CacheException catch (e) {
      log("[Repository] CacheException saving note: ${e.message}");
      return Left(CacheFailure("Failed to save note locally: ${e.message}"));
    } catch (e) {
      log("[Repository] Unexpected error saving note: $e");
      return Left(UnexpectedFailure("Failed to save note: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) async {
    log("[Repository] Marking note for deletion (ID: $id)...");
    try {
      final existingModel = await localDataSource.getNoteById(id);

      if (existingModel == null) {
        log(
          "[Repository] Note ID '$id' not found locally for deletion marking.",
        );
        return Left(CacheFailure("Note not found locally."));
      }

      final noteToDelete = existingModel.copyWith(isDeleted: true);
      await localDataSource.saveNote(noteToDelete);

      log(
        "[Repository] Marked note ID '$id' as deleted locally (isSynced: ${noteToDelete.isSynced}).",
      );
      return const Right(null);
    } on CacheException catch (e) {
      log(
        "[Repository] CacheException marking note for deletion: ${e.message}",
      );
      return Left(
        CacheFailure("Failed to mark note for deletion locally: ${e.message}"),
      );
    } catch (e) {
      log("[Repository] Unexpected error marking note for deletion: $e");
      return Left(
        UnexpectedFailure("Failed to mark note for deletion: ${e.toString()}"),
      );
    }
  }

  @override
  Future<Either<Failure, void>> syncNotes() async {
    log("[Repository] Starting sync process...");
    if (!connectivityService.isConnected) {
      log("[Repository] Sync skipped: Device is offline.");

      return const Right(null);
    }

    log("[Repository] Device is online. Fetching unsynced notes...");
    List<NoteModel> unsyncedNotes;
    try {
      unsyncedNotes = await localDataSource.getUnsyncedNotes();
      log("[Repository] Found ${unsyncedNotes.length} unsynced notes.");
    } on CacheException catch (e) {
      log(
        "[Repository] Sync failed: Could not retrieve unsynced notes. ${e.message}",
      );
      return Left(CacheFailure("Sync failed: ${e.message}"));
    } catch (e) {
      log(
        "[Repository] Sync failed: Unexpected error retrieving unsynced notes. $e",
      );
      return Left(UnexpectedFailure("Sync failed: ${e.toString()}"));
    }

    if (unsyncedNotes.isEmpty) {
      log("[Repository] No notes to sync.");
      return const Right(null);
    }

    int successCount = 0;
    int failureCount = 0;
    List<String> failureMessages = [];

    final notesToDelete = unsyncedNotes.where((n) => n.isDeleted).toList();
    final notesToSave = unsyncedNotes.where((n) => !n.isDeleted).toList();

    log("[Repository] Syncing ${notesToDelete.length} deletions...");
    for (final note in notesToDelete) {
      try {
        await remoteDataSource.deleteNoteFromFirestore(note.id);

        await localDataSource.deleteNoteById(note.id);
        successCount++;
        log("[Repository] Synced deletion for ID '${note.id}'.");
      } on ServerException catch (e) {
        failureCount++;
        failureMessages.add("Delete ID ${note.id}: ${e.message}");
        log(
          "[Repository] Failed to sync deletion for ID '${note.id}': ${e.message}",
        );
      } catch (e) {
        failureCount++;
        failureMessages.add(
          "Delete ID ${note.id}: Unexpected error ${e.toString()}",
        );
        log(
          "[Repository] Failed to sync deletion for ID '${note.id}': Unexpected error $e",
        );
      }
    }

    log("[Repository] Syncing ${notesToSave.length} saves/updates...");
    for (final note in notesToSave) {
      try {
        await remoteDataSource.saveNoteToFirestore(note);

        final syncedNote = note.copyWith(isSynced: true);
        await localDataSource.saveNote(syncedNote);
        successCount++;
        log("[Repository] Synced save/update for ID '${note.id}'.");
      } on ServerException catch (e) {
        failureCount++;
        failureMessages.add("Save ID ${note.id}: ${e.message}");
        log(
          "[Repository] Failed to sync save/update for ID '${note.id}': ${e.message}",
        );
      } catch (e) {
        failureCount++;
        failureMessages.add(
          "Save ID ${note.id}: Unexpected error ${e.toString()}",
        );
        log(
          "[Repository] Failed to sync save/update for ID '${note.id}': Unexpected error $e",
        );
      }
    }

    log(
      "[Repository] Sync finished. Success: $successCount, Failures: $failureCount.",
    );

    if (failureCount > 0) {
      return Left(
        ServerFailure(
          "Sync completed with $failureCount failures. Messages: ${failureMessages.join('; ')}",
        ),
      );
    } else {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, List<NoteEntity>>> refreshNotesFromRemote() async {
    log("[Repository] Refreshing notes from remote...");
    if (!connectivityService.isConnected) {
      log("[Repository] Refresh skipped: Device is offline.");
      return Left(NetworkFailure("Cannot refresh notes while offline."));
    }

    try {
      log("[Repository] Fetching latest notes from Firestore...");
      final List<NoteModel> remoteNotes =
          await remoteDataSource.getNotesFromFirestore();
      log("[Repository] Fetched ${remoteNotes.length} notes from remote.");

      log("[Repository] Clearing local cache before refresh...");
      await localDataSource.clearAll();
      log(
        "[Repository] Saving ${remoteNotes.length} refreshed notes locally...",
      );
      for (final note in remoteNotes) {
        await localDataSource.saveNote(note);
      }
      log("[Repository] Local cache updated with refreshed notes.");

      return Right(remoteNotes);
    } on ServerException catch (e) {
      log("[Repository] Refresh failed: ServerException: ${e.message}");
      return Left(
        ServerFailure("Failed to refresh notes from server: ${e.message}"),
      );
    } on CacheException catch (e) {
      log(
        "[Repository] Refresh failed: CacheException during update: ${e.message}",
      );
      return Left(
        CacheFailure(
          "Failed to update local cache after refresh: ${e.message}",
        ),
      );
    } catch (e) {
      log("[Repository] Refresh failed: Unexpected error: $e");
      return Left(
        UnexpectedFailure("Failed to refresh notes: ${e.toString()}"),
      );
    }
  }
}
