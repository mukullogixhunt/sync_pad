// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:sync_pad/core/error/exceptions.dart';
import 'package:sync_pad/features/auth/data/models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<AuthUserModel?> get authStateChanges;

  Future<AuthUserModel?> getCurrentUser();

  Future<AuthUserModel> loginWithEmail(String email, String password);

  Future<AuthUserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();

  Future<List<AuthUserModel>> getAllUsers();

}

class FirebaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRemoteDataSourceImpl({
    required firebase.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<AuthUserModel?> _userFromFirebase(firebase.User? firebaseUser) async {
    if (firebaseUser == null) {
      return null;
    }
    try {
      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        return AuthUserModel.fromFirestore(userDoc);
      } else {
        log(
          "Warning: Auth user exists but no Firestore document found for UID: ${firebaseUser.uid}",
        );
        return AuthUserModel.fromFirebaseAuth(firebaseUser);
      }
    } catch (e) {
      log("Error fetching user profile: $e");
      return null;
    }
  }

  @override
  Stream<AuthUserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap(_userFromFirebase);
  }

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    return await _userFromFirebase(_firebaseAuth.currentUser);
  }

  @override
  Future<AuthUserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw ServerException('Sign up failed, please try again.');
      }

      final newUser = AuthUserModel(
        uid: firebaseUser.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _usersCollection.doc(firebaseUser.uid).set(newUser.toFirestore());

      return newUser;
    } on firebase.FirebaseAuthException catch (e) {
      log('FirebaseAuthException on sign up: ${e.code}');
      throw ServerException(
        e.message ?? 'An unknown authentication error occurred.',
      );
    }
  }

  @override
  Future<AuthUserModel> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw ServerException('Login failed, please try again.');
      }

      final userModel = await _userFromFirebase(firebaseUser);
      if (userModel == null) {
        throw ServerException(
          'User profile not found. Please contact support.',
        );
      }
      return userModel;
    } on firebase.FirebaseAuthException catch (e) {
      log('FirebaseAuthException on login: ${e.code}');
      throw ServerException(
        e.message ?? 'An unknown authentication error occurred.',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase.FirebaseAuthException catch (e) {
      log('FirebaseAuthException on password reset: ${e.code}');
      throw ServerException(
        e.message ?? 'Failed to send password reset email.',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } on firebase.FirebaseAuthException catch (e) {
      log('FirebaseAuthException on logout: ${e.code}');
      throw ServerException(e.message ?? 'Failed to log out.');
    }
  }

  @override
  Future<List<AuthUserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _usersCollection.get();
      final currentUserUid = _firebaseAuth.currentUser?.uid;
      return querySnapshot.docs
          .where((doc) => doc.id != currentUserUid)
          .map((doc) => AuthUserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } on firebase.FirebaseException catch (e) {
      log("FirebaseAuthException on getting all users: ${e.code}");
      throw ServerException(e.message ?? 'Failed to fetch users.');
    }
  }
}
