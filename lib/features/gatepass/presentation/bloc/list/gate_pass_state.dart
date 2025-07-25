part of 'gate_pass_bloc.dart';

sealed class GatePassState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class GatePassInitial extends GatePassState {}

class GatePassLoading extends GatePassState {}

class GatePassLoaded extends GatePassState {
  final List<GatePassEntity> gatePasses;

  GatePassLoaded(this.gatePasses);

  @override
  List<Object?> get props => [gatePasses];
}

class GatePassFailure extends GatePassState {
  final String message;

  GatePassFailure(this.message);

  @override
  List<Object?> get props => [message];
}
