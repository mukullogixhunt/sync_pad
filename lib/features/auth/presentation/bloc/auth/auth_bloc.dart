import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/auth_user_entity.dart';
import '../../../domain/usecases/get_auth_state_changes.dart';
import '../../../domain/usecases/logout_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthStateChanges _getAuthStateChanges;
  final LogoutUser _logoutUser;
  late final StreamSubscription<AuthUserEntity?> _userSubscription;

  AuthBloc({
    required GetAuthStateChanges getAuthStateChanges,
    required LogoutUser logoutUser,
  }) : _getAuthStateChanges = getAuthStateChanges,
       _logoutUser = logoutUser,
       super(const AuthState.unknown()) {
    on<_AuthStateChanged>(_onAuthStateChanged);
    on<LogoutRequested>(_onLogoutRequested);

    _userSubscription = _getAuthStateChanges.call().listen(
      (user) => add(_AuthStateChanged(user)),
    );
  }

  void _onAuthStateChanged(_AuthStateChanged event, Emitter<AuthState> emit) {
    emit(
      event.user != null
          ? AuthState.authenticated(event.user!)
          : const AuthState.unauthenticated(),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUser(NoParams());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
