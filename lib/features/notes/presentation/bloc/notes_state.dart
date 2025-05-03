
part of 'notes_bloc.dart'; 

enum NotesStatus { initial, loading, loaded, syncing, refreshing, failure }

class NotesState extends Equatable {
  final NotesStatus status;
  final List<NoteEntity> notes; 
  final String? errorMessage; 
  final bool isConnected; 

  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const <NoteEntity>[],
    this.errorMessage,
    this.isConnected = true, 
  });

  NotesState copyWith({
    NotesStatus? status,
    List<NoteEntity>? notes,
    String? errorMessage,
    bool? isConnected,
    bool clearError = false, 
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage, isConnected];
}