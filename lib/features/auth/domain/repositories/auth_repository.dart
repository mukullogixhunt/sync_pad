// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';

abstract class AuthRepository {
  Stream<AuthUserEntity?> get authStateChanges;
  Future<Either<Failure, AuthUserEntity>> loginWithEmail(
      String email, String password);
  Future<Either<Failure, AuthUserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthUserEntity?>> getCurrentUser();


  Future<Either<Failure, List<AuthUserEntity>>> getAllUsers();


}