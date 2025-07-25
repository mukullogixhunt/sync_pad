// lib/features/auth/domain/usecases/get_current_user.dart
import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<AuthUserEntity?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser({required this.repository});

  @override
  Future<Either<Failure, AuthUserEntity?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}