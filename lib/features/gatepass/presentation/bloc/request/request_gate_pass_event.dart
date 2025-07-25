part of 'request_gate_pass_bloc.dart';

sealed class RequestGatePassEvent extends Equatable {
  const RequestGatePassEvent();
  @override
  List<Object> get props => [];
}

class SubmitNewRequest extends RequestGatePassEvent {
  final RequestGatePassParams params;
  const SubmitNewRequest({required this.params});
}

class UpdateStatusRequested extends RequestGatePassEvent {
  final String passId;
  final String newStatus;
  const UpdateStatusRequested({required this.passId, required this.newStatus});
}
