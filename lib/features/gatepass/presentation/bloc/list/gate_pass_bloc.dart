import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/features/gatepass/domain/usecases/get_gate_passes_usecase.dart';

import '../../../domain/entities/gate_pass_entity.dart';

part 'gate_pass_event.dart';
part 'gate_pass_state.dart';

class GatePassBloc extends Bloc<GatePassEvent, GatePassState> {
  final GetGatePassesUseCase getGatePassesUseCase;

  GatePassBloc({required this.getGatePassesUseCase})
    : super(GatePassInitial()) {
    on<GatePassEvent>((event, emit) {});

    on<GetGatePassEvent>(_onGetGatePassEvent);
  }

  Future<void> _onGetGatePassEvent(
    GetGatePassEvent event,
    Emitter<GatePassState> emit,
  ) async {
    emit(GatePassLoading());
    emit(GatePassLoading());
    final result = await getGatePassesUseCase(
      GetGatePassesParams(userId: event.userId),
    );

    result.fold(
      (failure) =>
          emit(GatePassFailure(failure.message ?? 'An error occurred')),
      (gatePasses) => emit(GatePassLoaded(gatePasses)),
    );
  }
}
