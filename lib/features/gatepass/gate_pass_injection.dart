import 'package:sync_pad/features/gatepass/data/datasources/gate_pass_remote_datasource.dart';
import 'package:sync_pad/features/gatepass/data/repositories/gate_pass_repository_impl.dart';
import 'package:sync_pad/features/gatepass/domain/repositories/gate_pass_repository.dart';
import 'package:sync_pad/features/gatepass/domain/usecases/get_gate_passes_usecase.dart';
import 'package:sync_pad/features/gatepass/domain/usecases/request_gate_pass_usecase.dart';
import 'package:sync_pad/features/gatepass/domain/usecases/update_gate_pass_status_usecase.dart';
import 'package:sync_pad/features/gatepass/presentation/bloc/list/gate_pass_bloc.dart';
import 'package:sync_pad/features/gatepass/presentation/bloc/request/request_gate_pass_bloc.dart';
import 'package:sync_pad/injection_container.dart';

void initGatePassFeature() {
  // --- Bloc ---
  sl.registerFactory(() => GatePassBloc(getGatePassesUseCase: sl()));
  sl.registerFactory(
    () => RequestGatePassBloc(
      requestGatePassUseCase: sl(),
      updateGatePassStatusUseCase: sl(),
    ),
  );

  // --- Use Cases ---
  sl.registerLazySingleton(() => GetGatePassesUseCase(repository: sl()));
  sl.registerLazySingleton(() => RequestGatePassUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateGatePassStatusUseCase(repository: sl()));

  // --- Repository ---
  sl.registerLazySingleton<GatePassRepository>(
    () => GatePassRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Data Source ---
  sl.registerLazySingleton<GatePassRemoteDataSource>(
    () => GatePassRemoteDataSourceImpl(firestore: sl()),
  );
}
