// lib/features/auth/domain/usecases/signup_user.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/auth/domain/repositories/auth_repository.dart';

class SignUpUser implements UseCase<AuthUserEntity, SignUpUserParams> {
  final AuthRepository repository;

  SignUpUser({required this.repository});

  @override
  Future<Either<Failure, AuthUserEntity>> call(SignUpUserParams params) async {
    return await repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

class SignUpUserParams extends Equatable {
  final String email;
  final String password;
  final String displayName;

  const SignUpUserParams({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}