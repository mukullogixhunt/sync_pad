// lib/features/notes/notes_injection.dart
import 'package:sync_pad/features/notes/data/datasources/local/local_note_datasource.dart';
import 'package:sync_pad/features/notes/data/datasources/remote/remote_note_datasource.dart';
import 'package:sync_pad/features/notes/data/repositories/note_repository_impl.dart';
import 'package:sync_pad/features/notes/domain/repositories/note_repository.dart';
import 'package:sync_pad/features/notes/domain/usecases/delete_note.dart';
import 'package:sync_pad/features/notes/domain/usecases/get_notes.dart';
import 'package:sync_pad/features/notes/domain/usecases/refresh_notes.dart';
import 'package:sync_pad/features/notes/domain/usecases/save_note.dart';
import 'package:sync_pad/features/notes/domain/usecases/sync_notes.dart';
import 'package:sync_pad/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:sync_pad/injection_container.dart'; // Access sl

void initNotesFeature() {
  // --- Bloc ---
  sl.registerFactory(
        () => NotesBloc(
      getNotes: sl(),
      saveNote: sl(),
      deleteNote: sl(),
      syncNotes: sl(),
      refreshNotes: sl(),
      connectivityService: sl(), // Inject connectivity here for sync trigger
    ),
  );

  // --- Use Cases ---
  sl.registerLazySingleton(() => GetNotes(repository: sl()));
  sl.registerLazySingleton(() => SaveNote(repository: sl()));
  sl.registerLazySingleton(() => DeleteNote(repository: sl()));
  sl.registerLazySingleton(() => SyncNotes(repository: sl()));
  sl.registerLazySingleton(() => RefreshNotes(repository: sl()));

  // --- Repository ---
  sl.registerLazySingleton<NoteRepository>(
        () => NoteRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivityService: sl(),
    ),
  );

  // --- Data Sources ---
  sl.registerLazySingleton<LocalNoteDataSource>(
        () => HiveLocalNoteDataSourceImpl(),
  );
  sl.registerLazySingleton<RemoteNoteDataSource>(
        () => FirestoreRemoteNoteDataSourceImpl(firestore: sl()),
  );
}