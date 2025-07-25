// lib/features/auth/domain/usecases/logout_user.dart
import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/auth/domain/repositories/auth_repository.dart';

class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUser({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}