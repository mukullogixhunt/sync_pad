import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/features/gatepass/domain/usecases/update_gate_pass_status_usecase.dart';

import '../../../domain/usecases/request_gate_pass_usecase.dart';

part 'request_gate_pass_event.dart';
part 'request_gate_pass_state.dart';

class RequestGatePassBloc
    extends Bloc<RequestGatePassEvent, RequestGatePassState> {
  final RequestGatePassUseCase requestGatePassUseCase;
  final UpdateGatePassStatusUseCase updateGatePassStatusUseCase;

  RequestGatePassBloc({
    required this.requestGatePassUseCase,
    required this.updateGatePassStatusUseCase,
  }) : super(RequestGatePassInitial()) {
    on<RequestGatePassEvent>((event, emit) {});

    on<SubmitNewRequest>(_onSubmitNewRequest);
    on<UpdateStatusRequested>(_onUpdateStatusRequested);
  }

  FutureOr<void> _onSubmitNewRequest(
    SubmitNewRequest event,
    Emitter<RequestGatePassState> emit,
  ) async {
    emit(RequestGatePassLoading());
    final result = await requestGatePassUseCase(event.params);

    result.fold(
      (failure) =>
          emit(RequestGatePassError(failure.message ?? 'An error occurred')),
      (gatePassId) => emit(RequestGatePassSuccess(gatePassId)),
    );
  }

  FutureOr<void> _onUpdateStatusRequested(
    UpdateStatusRequested event,
    Emitter<RequestGatePassState> emit,
  ) async {
    emit(RequestGatePassLoading());
    final result = await updateGatePassStatusUseCase(
      UpdateGatePassStatusParams(
        passId: event.passId,
        newStatus: event.newStatus,
      ),
    );

    result.fold(
      (failure) =>
          emit(RequestGatePassError(failure.message ?? 'An error occurred')),
      (_) => emit(RequestGatePassUpdated()),
    );
  }
}
