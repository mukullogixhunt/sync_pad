// lib/features/auth/domain/usecases/get_all_users.dart
import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/auth/domain/repositories/auth_repository.dart';

class GetAllUsers implements UseCase<List<AuthUserEntity>, NoParams> {
  final AuthRepository repository;

  GetAllUsers({required this.repository});

  @override
  Future<Either<Failure, List<AuthUserEntity>>> call(NoParams params) async {
    return await repository.getAllUsers();
  }
}