part of 'auth_form_bloc.dart';

sealed class AuthFormEvent extends Equatable {
  const AuthFormEvent();
  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthFormEvent {
  final String email;
  final String password;
  const LoginSubmitted({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class SignUpSubmitted extends AuthFormEvent {
  final String email;
  final String password;
  final String displayName;
  const SignUpSubmitted({required this.email, required this.password, required this.displayName});
  @override
  List<Object> get props => [email, password, displayName];
}

class PasswordResetRequested extends AuthFormEvent {
  final String email;
  const PasswordResetRequested({required this.email});
  @override
  List<Object> get props => [email];
}
