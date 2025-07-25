part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class _AuthStateChanged extends AuthEvent {
  final AuthUserEntity? user;
  const _AuthStateChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class LogoutRequested extends AuthEvent {}
