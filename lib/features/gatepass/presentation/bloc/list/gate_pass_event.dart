part of 'gate_pass_bloc.dart';

sealed class GatePassEvent extends Equatable {
  @override
  List<Object?> get props => [];
}



class GetGatePassEvent extends GatePassEvent {
  final String userId;

  GetGatePassEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
