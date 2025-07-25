// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/exceptions.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<AuthUserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<Either<Failure, AuthUserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> loginWithEmail(
      String email, String password) async {
    try {
      final user = await remoteDataSource.loginWithEmail(email, password);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmail(email: email, password: password, displayName: displayName);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AuthUserEntity>>> getAllUsers() async {
    try {
      final users = await remoteDataSource.getAllUsers();
      return  Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}