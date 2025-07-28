import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';


class StorageService {
  final FirebaseStorage storage;

  const StorageService({required this.storage});

  /// Gets a fresh, valid download URL for a given Firebase Storage path.
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final ref = storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      // Handle cases where the file might not exist in storage
      throw Exception('Could not get download URL for path: $storagePath');
    }
  }

}
