// lib/features/auth/data/models/auth_user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    required super.createdAt,
  });

  factory AuthUserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AuthUserModel(
      uid: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory AuthUserModel.fromFirebaseAuth(firebase.User user) {
    return AuthUserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'No Name',
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}