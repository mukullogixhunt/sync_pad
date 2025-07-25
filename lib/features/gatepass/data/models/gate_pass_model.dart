import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_pad/features/gatepass/domain/entities/gate_pass_entity.dart';
import 'package:sync_pad/features/gatepass/domain/usecases/request_gate_pass_usecase.dart';

class GatePassModel extends GatePassEntity {
  const GatePassModel({
    required super.id,
    required super.lotNumber,
    required super.doNumber,
    required super.vehicleNumber,
    super.weight,
    super.centre,
    required super.partyName,
    required super.status,
    required super.requestedAt,
    required super.updatedAt,
    required super.requesterId,
    required super.requesterName,
    required super.approverId,
    required super.approverName,
    required super.involvedParties,
  });

  factory GatePassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GatePassModel(
      id: doc.id,
      lotNumber: data['lotNumber'],
      doNumber: data['doNumber'],
      vehicleNumber: data['vehicleNumber'],
      weight: data['weight'],
      centre: data['centre'],
      partyName: data['partyName'],
      status: data['status'],
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      requesterId: data['requesterId'],
      requesterName: data['requesterName'],
      approverId: data['approverId'],
      approverName: data['approverName'],
      involvedParties: List<String>.from(data['involvedParties']),
    );
  }

  static Map<String, dynamic> toFirestoreMap(RequestGatePassParams params) {
    return {
      'lotNumber': params.lotNumber,
      'doNumber': params.doNumber,
      'vehicleNumber': params.vehicleNumber,
      'weight': params.weight,
      'centre': params.centre,
      'partyName': params.partyName,
      'status': 'requested', // Initial status
      'requestedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'requesterId': params.requesterId,
      'requesterName': params.requesterName,
      'approverId': params.approverId,
      'approverName': params.approverName,
      'involvedParties': [params.requesterId, params.approverId],
    };
  }
}