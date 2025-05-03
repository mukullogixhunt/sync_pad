import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';

import '../../features/notes/data/models/note_model.dart';

class HiveBoxes {
  static const String notes = 'notes_box';
}

Future<void> initializeHive() async {
  try {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    log('Hive initialized successfully at path: ${appDocumentDir.path}');
    Hive.registerAdapter(NoteModelAdapter());
    await Hive.openBox<NoteModel>(HiveBoxes.notes); // Will add type later
  } catch (e) {
    log('Error initializing Hive: $e');
  }
}
