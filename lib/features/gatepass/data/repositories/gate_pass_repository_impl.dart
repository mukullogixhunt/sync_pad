import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/exceptions.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/features/gatepass/data/datasources/gate_pass_remote_datasource.dart';
import 'package:sync_pad/features/gatepass/domain/entities/gate_pass_entity.dart';
import 'package:sync_pad/features/gatepass/domain/repositories/gate_pass_repository.dart';
import 'package:sync_pad/features/gatepass/domain/usecases/request_gate_pass_usecase.dart';

class GatePassRepositoryImpl implements GatePassRepository {
  final GatePassRemoteDataSource remoteDataSource;

  GatePassRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<GatePassEntity>>> getGatePasses(
    String userId,
  ) async {
    try {
      final passes = await remoteDataSource.getGatePasses(userId);
      return Right(passes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> requestGatePass(
    RequestGatePassParams params,
  ) async {
    try {
      final data = await remoteDataSource.requestGatePass(params);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateGatePassStatus({
    required String passId,
    required String newStatus,
  }) async {
    try {
      await remoteDataSource.updateGatePassStatus(
        passId: passId,
        newStatus: newStatus,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
