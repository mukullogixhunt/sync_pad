import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_pad/core/database/hive_setup.dart';
import 'package:sync_pad/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:sync_pad/features/auth/presentation/bloc/auth_form/auth_form_bloc.dart';
import 'package:sync_pad/features/chat/presentation/bloc/chats/chats_bloc.dart';
import 'package:sync_pad/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:sync_pad/injection_container.dart' as di;

import 'features/auth/presentation/bloc/users/users_bloc.dart';
import 'features/auth/presentation/screens/auth_wrapper.dart';
import 'features/chat/presentation/bloc/chat_details/chat_details_bloc.dart';
import 'features/chat/presentation/bloc/messages/messages_bloc.dart';
import 'features/chat/presentation/bloc/read_message/read_message_bloc.dart';
import 'features/chat/presentation/bloc/send_message/send_message_bloc.dart';
import 'features/gatepass/presentation/bloc/list/gate_pass_bloc.dart';
import 'features/gatepass/presentation/bloc/request/request_gate_pass_bloc.dart';
import 'firebase_options.dart';

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
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => di.sl<AuthFormBloc>()),
        BlocProvider(
          create: (context) => di.sl<UsersBloc>()..add(GetAllUsersEvent()),
        ),
        BlocProvider(create: (context) => di.sl<NotesBloc>()),
        BlocProvider(create: (context) => di.sl<ChatsBloc>()),
        BlocProvider(create: (context) => di.sl<ChatDetailsBloc>()),
        BlocProvider(create: (context) => di.sl<ChatsBloc>()),
        BlocProvider(create: (context) => di.sl<MessagesBloc>()),
        BlocProvider(create: (context) => di.sl<ReadMessageBloc>()),
        BlocProvider(create: (context) => di.sl<SendMessageBloc>()),
        BlocProvider(create: (context) => di.sl<GatePassBloc>()),
        BlocProvider(create: (context) => di.sl<RequestGatePassBloc>()),
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
        // home: const NotesListScreen(),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
