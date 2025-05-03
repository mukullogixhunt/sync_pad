import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sync_pad/core/database/hive_setup.dart';
import 'package:sync_pad/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:sync_pad/features/notes/presentation/screens/notes_list_screen.dart';
import 'package:sync_pad/injection_container.dart' as di;
import 'firebase_options.dart';
import 'dart:developer';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log("App starting...");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log("Firebase initialized successfully.");
  } catch (e) {
    log("Error initializing Firebase: $e");
  }

  try {
    await di.configureDependencies();
    log("Dependencies configured.");
  } catch (e) {
    log("Error configuring dependencies: $e");
  }

  await initializeHive();
  log("Hive initialization attempted.");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotesBloc>(
          create: (context) => di.sl<NotesBloc>()..add(LoadNotesEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Sync Pad',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 1,
            scrolledUnderElevation: 1,
          ),
        ),
        home: const NotesListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
