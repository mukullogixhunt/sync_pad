import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_pad/core/error/exceptions.dart';
import 'package:sync_pad/features/gatepass/data/models/gate_pass_model.dart';
import 'package:sync_pad/features/gatepass/domain/usecases/request_gate_pass_usecase.dart';

abstract class GatePassRemoteDataSource {
  Future<List<GatePassModel>> getGatePasses(String userId);

  Future<String> requestGatePass(RequestGatePassParams params);

  Future<void> updateGatePassStatus({
    required String passId,
    required String newStatus,
  });
}

class GatePassRemoteDataSourceImpl implements GatePassRemoteDataSource {
  final FirebaseFirestore firestore;

  GatePassRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _gatePassesCollection =>
      firestore.collection('gatepasses');

  @override
  Future<List<GatePassModel>> getGatePasses(String userId) async {
    try {
      final querySnapshot =
          await _gatePassesCollection
              .where('involvedParties', arrayContains: userId)
              .orderBy('requestedAt', descending: true)
              .get();
      return querySnapshot.docs
          .map((doc) => GatePassModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      log('Get Gate Pass');

      log(e.message ?? 'Failed to fetch gate passes.');
      throw ServerException(e.message ?? 'Failed to fetch gate passes.');
    }
  }

  @override
  Future<String> requestGatePass(RequestGatePassParams params) async {
    try {
      final docRef = _gatePassesCollection.doc();
      await docRef.set(GatePassModel.toFirestoreMap(params));
      return docRef.id; // <-- RETURN THE ID

    } on FirebaseException catch (e) {
      log('Request Gate Pass');

      log(e.message ?? 'Failed to create gate pass request.');

      throw ServerException(e.message ?? 'Failed to create gate pass request.');
    }
  }

  @override
  Future<void> updateGatePassStatus({
    required String passId,
    required String newStatus,
  }) async {
    try {
      final updateData = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Use the .update() method with the map.
      await _gatePassesCollection.doc(passId).update(updateData);

      log('Successfully updated gate pass $passId to status: $newStatus');    } on FirebaseException catch (e) {
      log('Update Gate Pass Status');
      log(e.message ?? 'Failed to update gate pass status.');

      throw ServerException(e.message ?? 'Failed to update gate pass status.');
    }
  }
}
