import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'core/network/connectivity_service.dart';
import 'features/notes/notes_injection.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl.registerSingleton<Connectivity>(Connectivity());
  sl.registerSingleton<ConnectivityService>(
    ConnectivityService(connectivity: sl()),
  );

  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  initNotesFeature();
}
