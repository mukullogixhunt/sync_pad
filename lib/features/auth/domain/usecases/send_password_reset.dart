// lib/features/auth/domain/usecases/send_password_reset.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordReset implements UseCase<void, SendPasswordResetParams> {
  final AuthRepository repository;

  SendPasswordReset({required this.repository});

  @override
  Future<Either<Failure, void>> call(SendPasswordResetParams params) async {
    return await repository.sendPasswordResetEmail(params.email);
  }
}

class SendPasswordResetParams extends Equatable {
  final String email;

  const SendPasswordResetParams({required this.email});

  @override
  List<Object?> get props => [email];
}