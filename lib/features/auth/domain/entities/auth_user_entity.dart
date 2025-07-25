// lib/features/auth/domain/entities/auth_user_entity.dart
import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  const AuthUserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [uid, email, displayName, createdAt];
}