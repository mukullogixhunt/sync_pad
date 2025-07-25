import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_pad/features/notes/data/models/note_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_pad/core/error/exceptions.dart';
import 'package:sync_pad/features/notes/data/models/note_model.dart';
import 'dart:developer';

abstract class RemoteNoteDataSource {
  Future<List<NoteModel>> getNotesFromFirestore();

  Future<void> saveNoteToFirestore(NoteModel note);

  Future<void> deleteNoteFromFirestore(String id);
}

class FirestoreRemoteNoteDataSourceImpl implements RemoteNoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth; // <-- 2. ADD FirebaseAuth instance variable


  // The constructor now requires both Firestore and FirebaseAuth
  FirestoreRemoteNoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth, // <-- 3. ADD to constructor
  });

  // late final CollectionReference _notesCollection;
  //
  // FirestoreRemoteNoteDataSourceImpl({required this.firestore}) {
  //   _notesCollection = firestore.collection('notes');
  // }


  // 4. CHANGE _notesCollection to a method that gets the current user's specific collection
  CollectionReference<Map<String, dynamic>> _getNotesCollection() {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      // This is a critical state. If no user is logged in, we cannot proceed.
      // Throwing an exception here is appropriate as it's an invalid state for this data source.
      throw ServerException('User is not authenticated. Cannot access notes.');
    }
    // This dynamically builds the correct path: 'users/{userId}/notes'
    return firestore.collection('users').doc(user.uid).collection('notes');
  }


  @override
  Future<List<NoteModel>> getNotesFromFirestore() async {
    try {
      final querySnapshot =
          await _getNotesCollection().orderBy('updatedAt', descending: true).get();

      final notes =
          querySnapshot.docs
              .map((doc) => NoteModel.fromFirestore(doc))
              .toList();
      log("Fetched ${notes.length} notes from Firestore.");
      return notes;
    } on FirebaseException catch (e) {
      log("FirebaseException fetching notes: ${e.code} - ${e.message}");
      throw ServerException("Failed to fetch notes from server: ${e.message}");
    } catch (e) {
      log("Error fetching notes from Firestore: $e");
      throw ServerException(
        "An unexpected error occurred while fetching notes.",
      );
    }
  }

  @override
  Future<void> saveNoteToFirestore(NoteModel note) async {
    try {
      await _getNotesCollection()
          .doc(note.id)
          .set(note.toFirestoreMap(), SetOptions(merge: true));
      log("Saved/Updated note ID '${note.id}' to Firestore.");
    } on FirebaseException catch (e) {
      log("FirebaseException saving note ${note.id}: ${e.code} - ${e.message}");
      throw ServerException("Failed to save note to server: ${e.message}");
    } catch (e) {
      log("Error saving note ${note.id} to Firestore: $e");
      throw ServerException(
        "An unexpected error occurred while saving the note.",
      );
    }
  }

  @override
  Future<void> deleteNoteFromFirestore(String id) async {
    try {
      await _getNotesCollection().doc(id).delete();
      log("Deleted note ID '$id' from Firestore.");
    } on FirebaseException catch (e) {
      log("FirebaseException deleting note $id: ${e.code} - ${e.message}");
      throw ServerException("Failed to delete note from server: ${e.message}");
    } catch (e) {
      log("Error deleting note $id from Firestore: $e");
      throw ServerException(
        "An unexpected error occurred while deleting the note.",
      );
    }
  }
}
