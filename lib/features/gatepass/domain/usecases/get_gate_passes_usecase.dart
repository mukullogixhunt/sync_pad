import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/gatepass/domain/entities/gate_pass_entity.dart';
import 'package:sync_pad/features/gatepass/domain/repositories/gate_pass_repository.dart';

class GetGatePassesUseCase implements UseCase<List<GatePassEntity>, GetGatePassesParams> {
  final GatePassRepository repository;
  GetGatePassesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<GatePassEntity>>> call(GetGatePassesParams params) async {
    return await repository.getGatePasses(params.userId);
  }
}

class GetGatePassesParams extends Equatable {
  final String userId;
  const GetGatePassesParams({required this.userId});
  @override
  List<Object?> get props => [userId];
}