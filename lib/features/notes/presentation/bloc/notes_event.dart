
part of 'notes_bloc.dart'; 

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}


class LoadNotesEvent extends NotesEvent {}



class _NotesUpdatedEvent extends NotesEvent {
  final List<NoteEntity> notes;
  const _NotesUpdatedEvent(this.notes);

  @override
  List<Object?> get props => [notes];
}



class SaveNoteEvent extends NotesEvent {
  
  
  final NoteEntity note;
  const SaveNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}


class DeleteNoteEvent extends NotesEvent {
  final String id;
  const DeleteNoteEvent(this.id);

  @override
  List<Object?> get props => [id];
}


class TriggerSyncEvent extends NotesEvent {}



class TriggerRefreshEvent extends NotesEvent {}


class ConnectivityChangedEvent extends NotesEvent {
  final bool isConnected;
  const ConnectivityChangedEvent(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}