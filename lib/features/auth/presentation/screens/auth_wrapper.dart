// lib/features/auth/presentation/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sync_pad/core/database/hive_setup.dart';
import 'package:sync_pad/features/auth/presentation/screens/login_screen.dart';
import 'package:sync_pad/features/notes/data/models/note_model.dart';
import 'package:sync_pad/features/notes/presentation/screens/notes_list_screen.dart';

import '../bloc/auth/auth_bloc.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          // When user logs out, clear their local data to ensure privacy
          Hive.box<NoteModel>(HiveBoxes.notes).clear();
        }

        if (state.status == AuthStatus.authenticated) {


          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NotesListScreen()),
            (Route<dynamic> route) => false, // remove all
          );
        }

        if (state.status == AuthStatus.unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false, // remove all
          );
        }
      },
      builder: (context, state) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
