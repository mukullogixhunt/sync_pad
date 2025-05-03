// import 'dart:async';
// import 'dart:developer';
//
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:sync_pad/core/network/connectivity_service.dart';
// import 'package:sync_pad/core/usecase/usecase.dart';
// import 'package:sync_pad/features/notes/domain/entities/note_entity.dart';
// import 'package:sync_pad/features/notes/domain/usecases/delete_note.dart';
// import 'package:sync_pad/features/notes/domain/usecases/get_notes.dart';
// import 'package:sync_pad/features/notes/domain/usecases/refresh_notes.dart';
// import 'package:sync_pad/features/notes/domain/usecases/save_note.dart';
// import 'package:sync_pad/features/notes/domain/usecases/sync_notes.dart';
//
// part 'notes_event.dart';
//
// part 'notes_state.dart';
//
// class NotesBloc extends Bloc<NotesEvent, NotesState> {
//   final GetNotes _getNotes;
//   final SaveNote _saveNote;
//   final DeleteNote _deleteNote;
//   final SyncNotes _syncNotes;
//   final RefreshNotes _refreshNotes;
//   final ConnectivityService _connectivityService;
//   StreamSubscription? _connectivitySubscription;
//
//   NotesBloc({
//     required GetNotes getNotes,
//     required SaveNote saveNote,
//     required DeleteNote deleteNote,
//     required SyncNotes syncNotes,
//     required RefreshNotes refreshNotes,
//     required ConnectivityService connectivityService,
//   }) : _getNotes = getNotes,
//        _saveNote = saveNote,
//        _deleteNote = deleteNote,
//        _syncNotes = syncNotes,
//        _refreshNotes = refreshNotes,
//        _connectivityService = connectivityService,
//
//        super(NotesState(isConnected: connectivityService.isConnected)) {
//     on<LoadNotesEvent>(_onLoadNotes);
//     on<_NotesUpdatedEvent>(_onNotesUpdated);
//     on<SaveNoteEvent>(_onSaveNote);
//     on<DeleteNoteEvent>(_onDeleteNote);
//     on<TriggerSyncEvent>(_onTriggerSync);
//     on<TriggerRefreshEvent>(_onTriggerRefresh);
//     on<ConnectivityChangedEvent>(_onConnectivityChanged);
//
//     add(ConnectivityChangedEvent(_connectivityService.isConnected));
//   }
//
//   @override
//   Future<void> close() {
//     _connectivitySubscription?.cancel();
//     return super.close();
//   }
//
//   Future<void> _onLoadNotes(
//     LoadNotesEvent event,
//     Emitter<NotesState> emit,
//   ) async {
//     log('[Bloc] Handling LoadNotesEvent...');
//
//     emit(state.copyWith(status: NotesStatus.loading, clearError: true));
//
//     final failureOrNotes = await _getNotes(NoParams());
//
//     NotesStatus statusAfterLocalLoad = NotesStatus.loaded;
//     List<NoteEntity> notesToShow = [];
//
//     failureOrNotes.fold(
//       (failure) {
//         log('[Bloc] LoadNotesEvent failed locally: ${failure.message}');
//
//         statusAfterLocalLoad = NotesStatus.failure;
//         emit(
//           state.copyWith(
//             status: statusAfterLocalLoad,
//             errorMessage: failure.message,
//           ),
//         );
//       },
//       (localNotes) {
//         log('[Bloc] LoadNotesEvent got ${localNotes.length} notes locally.');
//         notesToShow = localNotes;
//
//         emit(state.copyWith(status: statusAfterLocalLoad, notes: notesToShow));
//       },
//     );
//
//     final bool currentlyConnected = _connectivityService.isConnected;
//     if (currentlyConnected) {
//       log(
//         '[Bloc] Online after initial local load. Triggering refresh from remote...',
//       );
//       add(TriggerRefreshEvent());
//     } else {
//       log('[Bloc] Offline after initial local load. Sticking with local data.');
//
//       if (statusAfterLocalLoad == NotesStatus.failure && notesToShow.isEmpty) {
//       } else {
//         emit(state.copyWith(status: NotesStatus.loaded, notes: notesToShow));
//       }
//     }
//   }
//
//   void _onNotesUpdated(_NotesUpdatedEvent event, Emitter<NotesState> emit) {
//     log('[Bloc] Handling _NotesUpdatedEvent...');
//     emit(state.copyWith(status: NotesStatus.loaded, notes: event.notes));
//   }
//
//   Future<void> _onSaveNote(
//     SaveNoteEvent event,
//     Emitter<NotesState> emit,
//   ) async {
//     log('[Bloc] Handling SaveNoteEvent...');
//
//     final failureOrNote = await _saveNote(SaveNoteParams(note: event.note));
//
//     await failureOrNote.fold(
//       (failure) async {
//         log('[Bloc] SaveNoteEvent failed: ${failure.message}');
//         emit(
//           state.copyWith(
//             status: NotesStatus.failure,
//             errorMessage: failure.message,
//           ),
//         );
//       },
//       (savedNote) async {
//         log('[Bloc] SaveNoteEvent succeeded locally.');
//
//         await _refreshLocalNotes(emit, NotesStatus.loaded);
//
//         if (state.isConnected) {
//           log('[Bloc] Triggering sync after local save...');
//           add(TriggerSyncEvent());
//         }
//       },
//     );
//   }
//
//   Future<void> _onDeleteNote(
//     DeleteNoteEvent event,
//     Emitter<NotesState> emit,
//   ) async {
//     log('[Bloc] Handling DeleteNoteEvent for ID: ${event.id}...');
//
//     final failureOrSuccess = await _deleteNote(DeleteNoteParams(id: event.id));
//
//     await failureOrSuccess.fold(
//       (failure) async {
//         log('[Bloc] DeleteNoteEvent failed: ${failure.message}');
//         emit(
//           state.copyWith(
//             status: NotesStatus.failure,
//             errorMessage: failure.message,
//           ),
//         );
//       },
//       (_) async {
//         log('[Bloc] DeleteNoteEvent marked locally.');
//
//         await _refreshLocalNotes(emit, NotesStatus.loaded);
//
//         if (state.isConnected) {
//           log('[Bloc] Triggering sync after local delete mark...');
//           add(TriggerSyncEvent());
//         }
//       },
//     );
//   }
//
//   Future<void> _onTriggerSync(
//     TriggerSyncEvent event,
//     Emitter<NotesState> emit,
//   ) async {
//     log('[Bloc] Handling TriggerSyncEvent...');
//
//     if (state.status == NotesStatus.syncing) {
//       log('[Bloc] Sync already in progress. Skipping.');
//       return;
//     }
//     if (!state.isConnected) {
//       log('[Bloc] Sync skipped: No connection.');
//
//       return;
//     }
//
//     emit(state.copyWith(status: NotesStatus.syncing, clearError: true));
//
//     final failureOrSuccess = await _syncNotes(NoParams());
//
//     await failureOrSuccess.fold(
//       (failure) async {
//         log('[Bloc] Sync failed: ${failure.message}');
//
//         emit(
//           state.copyWith(
//             status: NotesStatus.failure,
//             errorMessage: "Sync failed: ${failure.message}",
//           ),
//         );
//
//         await _refreshLocalNotes(emit, NotesStatus.failure);
//       },
//       (_) async {
//         log('[Bloc] Sync successful.');
//
//         await _refreshLocalNotes(emit, NotesStatus.loaded);
//       },
//     );
//   }
//
//   Future<void> _onTriggerRefresh(
//     TriggerRefreshEvent event,
//     Emitter<NotesState> emit,
//   ) async {
//     log('[Bloc] Handling TriggerRefreshEvent...');
//     if (!state.isConnected) {
//       log('[Bloc] Refresh skipped: No connection.');
//       emit(
//         state.copyWith(
//           status: NotesStatus.failure,
//           errorMessage: "Cannot refresh while offline.",
//         ),
//       );
//       return;
//     }
//     emit(state.copyWith(status: NotesStatus.refreshing, clearError: true));
//
//     final failureOrNotes = await _refreshNotes(NoParams());
//
//     failureOrNotes.fold(
//       (failure) {
//         log('[Bloc] Refresh failed: ${failure.message}');
//         emit(
//           state.copyWith(
//             status: NotesStatus.failure,
//             errorMessage: failure.message,
//           ),
//         );
//       },
//       (notes) {
//         log('[Bloc] Refresh succeeded. Fetched ${notes.length} notes.');
//
//         emit(state.copyWith(status: NotesStatus.loaded, notes: notes));
//       },
//     );
//   }
//
//   void _onConnectivityChanged(
//     ConnectivityChangedEvent event,
//     Emitter<NotesState> emit,
//   ) {
//     log(
//       '[Bloc] Handling ConnectivityChangedEvent: isConnected=${event.isConnected}',
//     );
//     if (state.isConnected != event.isConnected) {
//       emit(state.copyWith(isConnected: event.isConnected));
//     }
//   }
//
//   Future<void> _refreshLocalNotes(
//     Emitter<NotesState> emit,
//     NotesStatus statusAfterRefresh,
//   ) async {
//     log('[Bloc] Refreshing local notes...');
//     final failureOrNotes = await _getNotes(NoParams());
//     failureOrNotes.fold(
//       (f) => emit(
//         state.copyWith(
//           status: NotesStatus.failure,
//           errorMessage: "Failed to reload notes after operation: ${f.message}",
//         ),
//       ),
//       (n) => emit(
//         state.copyWith(status: statusAfterRefresh, notes: n, clearError: true),
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:sync_pad/core/network/connectivity_service.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/notes/domain/entities/note_entity.dart';
import 'package:sync_pad/features/notes/domain/usecases/delete_note.dart';
import 'package:sync_pad/features/notes/domain/usecases/get_notes.dart';
import 'package:sync_pad/features/notes/domain/usecases/refresh_notes.dart';
import 'package:sync_pad/features/notes/domain/usecases/save_note.dart';
import 'package:sync_pad/features/notes/domain/usecases/sync_notes.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotes _getNotes;
  final SaveNote _saveNote;
  final DeleteNote _deleteNote;
  final SyncNotes _syncNotes;
  final RefreshNotes _refreshNotes;
  final ConnectivityService _connectivityService;



  late final VoidCallback _connectivityListener;

  NotesBloc({
    required GetNotes getNotes,
    required SaveNote saveNote,
    required DeleteNote deleteNote,
    required SyncNotes syncNotes,
    required RefreshNotes refreshNotes,
    required ConnectivityService connectivityService,
  })  : _getNotes = getNotes,
        _saveNote = saveNote,
        _deleteNote = deleteNote,
        _syncNotes = syncNotes,
        _refreshNotes = refreshNotes,
        _connectivityService = connectivityService,

        super(NotesState(isConnected: connectivityService.isConnected)) {


    _connectivityListener = () {

      final isConnected = _connectivityService.isConnected;
      log("[Bloc Listener Callback] Connectivity changed detected: isConnected=$isConnected");

      add(ConnectivityChangedEvent(isConnected));
    };


    on<LoadNotesEvent>(_onLoadNotes);
    on<_NotesUpdatedEvent>(_onNotesUpdated);
    on<SaveNoteEvent>(_onSaveNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<TriggerSyncEvent>(_onTriggerSync);
    on<TriggerRefreshEvent>(_onTriggerRefresh);

    on<ConnectivityChangedEvent>(_onConnectivityChanged);


    _connectivityService.connectionStatusNotifier.addListener(_connectivityListener);
    log("[Bloc] Added connectivity listener.");


    add(ConnectivityChangedEvent(_connectivityService.isConnected));



  }


  @override
  Future<void> close() {

    _connectivityService.connectionStatusNotifier.removeListener(_connectivityListener);
    log("[Bloc] Removed connectivity listener.");
    return super.close();
  }




  Future<void> _onLoadNotes(LoadNotesEvent event, Emitter<NotesState> emit) async {
    log('[Bloc] Handling LoadNotesEvent...');

    emit(state.copyWith(status: NotesStatus.loading, clearError: true));


    final failureOrNotes = await _getNotes(NoParams());

    await failureOrNotes.fold(
          (failure) async {
        log('[Bloc] LoadNotesEvent failed locally: ${failure.message}');

        emit(state.copyWith(
            status: NotesStatus.failure, errorMessage: failure.message));

        if (state.isConnected) {
          log('[Bloc] Local load failed but online, triggering refresh...');
          add(TriggerRefreshEvent());
        }
      },
          (localNotes) async {
        log('[Bloc] LoadNotesEvent got ${localNotes.length} notes locally.');

        emit(state.copyWith(status: NotesStatus.loaded, notes: localNotes));


        if (localNotes.isEmpty && state.isConnected) {
          log('[Bloc] Condition MET: Local cache empty and online, triggering initial refresh...');
          add(TriggerRefreshEvent());
        } else {
          log('[Bloc] Condition NOT MET for initial refresh (Empty: ${localNotes.isEmpty}, Connected: ${state.isConnected}).');
        }
      },
    );
  }


  void _onNotesUpdated(_NotesUpdatedEvent event, Emitter<NotesState> emit) {
    log('[Bloc] Handling _NotesUpdatedEvent with ${event.notes.length} notes.');

    emit(state.copyWith(status: NotesStatus.loaded, notes: event.notes));
  }


  Future<void> _onSaveNote(SaveNoteEvent event, Emitter<NotesState> emit) async {
    log('[Bloc] Handling SaveNoteEvent...');


    final failureOrNote = await _saveNote(SaveNoteParams(note: event.note));

    await failureOrNote.fold(
            (failure) async {
          log('[Bloc] SaveNoteEvent failed: ${failure.message}');
          emit(state.copyWith(status: NotesStatus.failure, errorMessage: failure.message));
        },
            (savedNote) async {
          log('[Bloc] SaveNoteEvent succeeded locally.');

          await _refreshLocalNotes(emit, NotesStatus.loaded);


          if (state.isConnected) {
            log('[Bloc] Triggering sync after local save...');
            add(TriggerSyncEvent());
          }
        }
    );
  }


  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NotesState> emit) async {
    log('[Bloc] Handling DeleteNoteEvent for ID: ${event.id}...');

    final failureOrSuccess = await _deleteNote(DeleteNoteParams(id: event.id));

    await failureOrSuccess.fold(
            (failure) async {
          log('[Bloc] DeleteNoteEvent failed: ${failure.message}');
          emit(state.copyWith(status: NotesStatus.failure, errorMessage: failure.message));
        },
            (_) async {
          log('[Bloc] DeleteNoteEvent marked locally.');

          await _refreshLocalNotes(emit, NotesStatus.loaded);


          if (state.isConnected) {
            log('[Bloc] Triggering sync after local delete mark...');
            add(TriggerSyncEvent());
          }
        }
    );
  }


  Future<void> _onTriggerSync(TriggerSyncEvent event, Emitter<NotesState> emit) async {
    log('[Bloc] Handling TriggerSyncEvent...');

    if (state.status == NotesStatus.syncing) {
      log('[Bloc] Sync already in progress. Skipping.');
      return;
    }

    if (!state.isConnected) {
      log('[Bloc] Sync skipped: No connection (checked state).');
      return;
    }

    emit(state.copyWith(status: NotesStatus.syncing, clearError: true));

    final failureOrSuccess = await _syncNotes(NoParams());

    await failureOrSuccess.fold(
          (failure) async {
        log('[Bloc] Sync failed: ${failure.message}');

        emit(state.copyWith(
          status: NotesStatus.failure,
          errorMessage: "Sync failed: ${failure.message}",
        ));


      },
          (_) async {
        log('[Bloc] Sync successful.');

        await _refreshLocalNotes(emit, NotesStatus.loaded);
      },
    );
  }


  Future<void> _onTriggerRefresh(TriggerRefreshEvent event, Emitter<NotesState> emit) async {
    log('[Bloc] Handling TriggerRefreshEvent...');

    if (!state.isConnected) {
      log('[Bloc] Refresh skipped: No connection (checked state).');
      emit(state.copyWith(status: NotesStatus.failure, errorMessage: "Cannot refresh while offline."));
      return;
    }

    emit(state.copyWith(status: NotesStatus.refreshing, clearError: true));

    final failureOrNotes = await _refreshNotes(NoParams());

    failureOrNotes.fold(
          (failure) {
        log('[Bloc] Refresh failed: ${failure.message}');
        emit(state.copyWith(status: NotesStatus.failure, errorMessage: failure.message));
      },
          (refreshedNotes) {
        log('[Bloc] Refresh succeeded. Fetched ${refreshedNotes.length} notes.');

        emit(state.copyWith(status: NotesStatus.loaded, notes: refreshedNotes));
      },
    );
  }


  void _onConnectivityChanged(ConnectivityChangedEvent event, Emitter<NotesState> emit) {
    log('[Bloc] Handling ConnectivityChangedEvent: isConnected=${event.isConnected}');

    if (state.isConnected != event.isConnected) {
      log('[Bloc] Connectivity status changed in state.');
      emit(state.copyWith(isConnected: event.isConnected));


      if (event.isConnected) {
        log('[Bloc] Connectivity changed to ONLINE. Triggering automatic sync.');
        add(TriggerSyncEvent());
      }
    } else {
      log('[Bloc] Connectivity status reported, but no change from current state.');
    }
  }





  Future<void> _refreshLocalNotes(Emitter<NotesState> emit, NotesStatus statusAfterRefresh) async {
    log('[Bloc] Helper: Refreshing local notes...');
    final failureOrNotes = await _getNotes(NoParams());
    failureOrNotes.fold(
            (f) {
          log('[Bloc Helper] Failed to refresh local notes: ${f.message}');

          emit(state.copyWith(status: NotesStatus.failure, errorMessage: "Failed to reload notes: ${f.message}"));
        },
            (n) {
          log('[Bloc Helper] Successfully refreshed local notes (${n.length}). Emitting state: $statusAfterRefresh');

          emit(state.copyWith(status: statusAfterRefresh, notes: n, clearError: true));
        }
    );
  }
}