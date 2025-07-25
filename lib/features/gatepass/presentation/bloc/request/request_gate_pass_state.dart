part of 'request_gate_pass_bloc.dart';

sealed class RequestGatePassState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class RequestGatePassInitial extends RequestGatePassState {}

class RequestGatePassLoading extends RequestGatePassState {}

class RequestGatePassSuccess extends RequestGatePassState {
  final String gatePassId;

  RequestGatePassSuccess(this.gatePassId);

  @override
  List<Object?> get props => [gatePassId];
}

class RequestGatePassUpdated extends RequestGatePassState {}

class RequestGatePassError extends RequestGatePassState {
  final String message;

  RequestGatePassError(this.message);

  @override
  List<Object?> get props => [message];
}
