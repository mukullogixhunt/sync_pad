import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/gatepass/domain/repositories/gate_pass_repository.dart';

class UpdateGatePassStatusUseCase implements UseCase<void, UpdateGatePassStatusParams> {
  final GatePassRepository repository;
  UpdateGatePassStatusUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(UpdateGatePassStatusParams params) async {
    return await repository.updateGatePassStatus(
      passId: params.passId,
      newStatus: params.newStatus,
    );
  }
}

class UpdateGatePassStatusParams extends Equatable {
  final String passId;
  final String newStatus;

  const UpdateGatePassStatusParams({required this.passId, required this.newStatus});

  @override
  List<Object?> get props => [passId, newStatus];
}