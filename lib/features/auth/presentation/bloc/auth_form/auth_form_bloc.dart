// lib/features/auth/presentation/bloc/auth_form_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/features/auth/domain/usecases/login_user.dart';
import 'package:sync_pad/features/auth/domain/usecases/send_password_reset.dart';
import 'package:sync_pad/features/auth/domain/usecases/signup_user.dart';

part 'auth_form_event.dart';

part 'auth_form_state.dart';

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  final LoginUser _loginUser;
  final SignUpUser _signUpUser;
  final SendPasswordReset _sendPasswordReset;

  AuthFormBloc({
    required LoginUser loginUser,
    required SignUpUser signUpUser,
    required SendPasswordReset sendPasswordReset,
  }) : _loginUser = loginUser,
       _signUpUser = signUpUser,
       _sendPasswordReset = sendPasswordReset,
       super(const AuthFormState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<PasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthFormState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading, clearMessages: true));
    final result = await _loginUser(
      LoginUserParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FormStatus.error,
          errorMessage:
              'Email or Password is incorrect\nOr your account does not exists',
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: FormStatus.success,
          successMessage: 'Logged In Successfully',
        ),
      ),
    );
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<AuthFormState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading, clearMessages: true));
    final result = await _signUpUser(
      SignUpUserParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.error, errorMessage: failure.message),
      ),
      (user) => emit(state.copyWith(status: FormStatus.success)),
    );
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthFormState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading, clearMessages: true));
    final result = await _sendPasswordReset(
      SendPasswordResetParams(email: event.email),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.error, errorMessage: failure.message),
      ),
      (_) => emit(
        state.copyWith(
          status: FormStatus.submitted,
          successMessage: 'Password reset link sent! Check your email.',
        ),
      ),
    );
  }
}
