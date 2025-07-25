// lib/features/auth/domain/usecases/login_user.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/auth/domain/repositories/auth_repository.dart';

class LoginUser implements UseCase<AuthUserEntity, LoginUserParams> {
  final AuthRepository repository;

  LoginUser({required this.repository});

  @override
  Future<Either<Failure, AuthUserEntity>> call(LoginUserParams params) async {
    return await repository.loginWithEmail(params.email, params.password);
  }
}

class LoginUserParams extends Equatable {
  final String email;
  final String password;

  const LoginUserParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}