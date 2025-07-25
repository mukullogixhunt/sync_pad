// lib/features/auth/presentation/bloc/auth_form_state.dart
part of 'auth_form_bloc.dart';

enum FormStatus { initial, loading, success, submitted, error }

class AuthFormState extends Equatable {
  final FormStatus status;
  final String? errorMessage;
  final String? successMessage;

  const AuthFormState({
    this.status = FormStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  AuthFormState copyWith({
    FormStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AuthFormState(
      status: status ?? this.status,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage];
}