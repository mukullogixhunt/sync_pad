part of 'users_bloc.dart';

sealed class UsersState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<AuthUserEntity> users;

  UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UsersFailure extends UsersState {
  final String message;

  UsersFailure(this.message);

  @override
  List<Object?> get props => [message];
}
