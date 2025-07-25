// lib/features/auth/domain/usecases/get_auth_state_changes.dart
import 'dart:async';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/auth/domain/repositories/auth_repository.dart';

// This is a special use case that returns a stream, so it doesn't follow the standard Future-based UseCase class.
class GetAuthStateChanges {
  final AuthRepository repository;

  GetAuthStateChanges({required this.repository});

  Stream<AuthUserEntity?> call() {
    return repository.authStateChanges;
  }
}