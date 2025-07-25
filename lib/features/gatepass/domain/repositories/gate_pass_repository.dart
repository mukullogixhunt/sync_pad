import 'package:dartz/dartz.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/features/gatepass/domain/entities/gate_pass_entity.dart';
import 'package:sync_pad/features/gatepass/domain/usecases/request_gate_pass_usecase.dart';

abstract class GatePassRepository {
  Future<Either<Failure, List<GatePassEntity>>> getGatePasses(String userId);
  Future<Either<Failure, String>> requestGatePass(RequestGatePassParams params);
  Future<Either<Failure, void>> updateGatePassStatus({
    required String passId,
    required String newStatus,
  });
}