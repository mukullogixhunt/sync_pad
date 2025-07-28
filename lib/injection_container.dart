import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'core/network/connectivity_service.dart';
import 'core/utils/storage_service.dart';
import 'features/auth/auth_injection.dart';
import 'features/chat/chats_injection.dart';
import 'features/gatepass/gate_pass_injection.dart';
import 'features/notes/notes_injection.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  sl.registerSingleton<Connectivity>(Connectivity());
  sl.registerSingleton<ConnectivityService>(
    ConnectivityService(connectivity: sl()),
  );

  // Firebase
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  sl.registerLazySingleton(() => StorageService(storage: sl()));

  // Features
  initAuthFeature();
  initNotesFeature();
  initChatFeature();
  initGatePassFeature();
}
