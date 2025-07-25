import 'package:equatable/equatable.dart';

class GatePassEntity extends Equatable {
  final String id;
  final String lotNumber;
  final String doNumber;
  final String vehicleNumber;
  final String? weight;
  final String? centre;
  final String partyName;
  final String status; // 'requested', 'accepted', 'declined', completed
  final DateTime requestedAt;
  final DateTime updatedAt;
  final String requesterId;
  final String requesterName;
  final String approverId;
  final String approverName;
  final List<String> involvedParties;

  const GatePassEntity({
    required this.id,
    required this.lotNumber,
    required this.doNumber,
    required this.vehicleNumber,
    this.weight,
    this.centre,
    required this.partyName,
    required this.status,
    required this.requestedAt,
    required this.updatedAt,
    required this.requesterId,
    required this.requesterName,
    required this.approverId,
    required this.approverName,
    required this.involvedParties,
  });

  @override
  List<Object?> get props => [id, status,partyName, lotNumber, doNumber, vehicleNumber];
}