import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/core/error/failures.dart';
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/gatepass/domain/repositories/gate_pass_repository.dart';

class RequestGatePassUseCase implements UseCase<String, RequestGatePassParams> {
  final GatePassRepository repository;
  RequestGatePassUseCase({required this.repository});

  @override
  Future<Either<Failure, String>> call(RequestGatePassParams params) async {
    return await repository.requestGatePass(params);
  }
}

class RequestGatePassParams extends Equatable {
  final String lotNumber;
  final String doNumber;
  final String vehicleNumber;
  final String? weight;
  final String? centre;
  final String requesterId;
  final String requesterName;
  final String approverId;
  final String approverName;
  final String partyName;

  const RequestGatePassParams({
    required this.lotNumber,
    required this.doNumber,
    required this.vehicleNumber,
    this.weight,
    this.centre,
    required this.requesterId,
    required this.requesterName,
    required this.approverId,
    required this.approverName,
    required this.partyName,
  });

  @override
  List<Object?> get props => [lotNumber, doNumber, vehicleNumber, requesterId, approverId,partyName];
}