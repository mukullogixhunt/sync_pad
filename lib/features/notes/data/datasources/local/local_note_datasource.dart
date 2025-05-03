import 'package:sync_pad/features/notes/data/models/note_model.dart';
import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:sync_pad/core/database/hive_setup.dart';
import 'package:sync_pad/core/error/exceptions.dart';
import 'package:sync_pad/features/notes/data/models/note_model.dart';

abstract class LocalNoteDataSource {
  Future<List<NoteModel>> getAllNotes();

  Future<NoteModel?> getNoteById(String id);

  Future<void> saveNote(NoteModel note);

  Future<void> deleteNoteById(String id);

  Future<List<NoteModel>> getUnsyncedNotes();

  Future<void> clearAll();
}

class HiveLocalNoteDataSourceImpl implements LocalNoteDataSource {
  Box<NoteModel> get _notesBox => Hive.box<NoteModel>(HiveBoxes.notes);

  @override
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final notes = _notesBox.values.where((note) => !note.isDeleted).toList();
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      log("Fetched ${notes.length} notes from Hive.");
      return notes;
    } catch (e) {
      log("Error fetching notes from Hive: $e");
      throw CacheException("Could not retrieve notes from local storage.");
    }
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    try {
      final note = _notesBox.get(id);
      log("Fetched note by ID '$id' from Hive: ${note != null}");

      return (note != null && !note.isDeleted) ? note : null;
    } catch (e) {
      log("Error fetching note by ID '$id' from Hive: $e");
      throw CacheException("Could not retrieve note by ID from local storage.");
    }
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    try {
      await _notesBox.put(note.id, note);
      log(
        "Saved note ID '${note.id}' to Hive. isSynced: ${note.isSynced}, isDeleted: ${note.isDeleted}",
      );
    } catch (e) {
      log("Error saving note ID '${note.id}' to Hive: $e");
      throw CacheException("Could not save note to local storage.");
    }
  }

  @override
  Future<void> deleteNoteById(String id) async {
    try {
      await _notesBox.delete(id);
      log("Permanently deleted note ID '$id' from Hive.");
    } catch (e) {
      log("Error deleting note ID '$id' from Hive: $e");
      throw CacheException("Could not delete note from local storage.");
    }
  }

  @override
  Future<List<NoteModel>> getUnsyncedNotes() async {
    try {
      final unsyncedNotes =
          _notesBox.values.where((note) => !note.isSynced).toList();
      log("Found ${unsyncedNotes.length} unsynced notes in Hive.");
      return unsyncedNotes;
    } catch (e) {
      log("Error fetching unsynced notes from Hive: $e");
      throw CacheException("Could not retrieve unsynced notes.");
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final count = await _notesBox.clear();
      log("Cleared $count notes from Hive box '${HiveBoxes.notes}'.");
    } catch (e) {
      log("Error clearing Hive notes box: $e");
      throw CacheException("Could not clear local note storage.");
    }
  }
}
