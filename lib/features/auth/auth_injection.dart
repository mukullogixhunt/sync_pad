// lib/features/auth/chat_injection.dart
import 'package:sync_pad/core/usecase/usecase.dart';
import 'package:sync_pad/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sync_pad/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sync_pad/features/auth/domain/repositories/auth_repository.dart';
import 'package:sync_pad/features/auth/domain/usecases/get_auth_state_changes.dart';
import 'package:sync_pad/features/auth/domain/usecases/get_current_user.dart';
import 'package:sync_pad/features/auth/domain/usecases/login_user.dart';
import 'package:sync_pad/features/auth/domain/usecases/logout_user.dart';
import 'package:sync_pad/features/auth/domain/usecases/send_password_reset.dart';
import 'package:sync_pad/features/auth/domain/usecases/signup_user.dart';
import 'package:sync_pad/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:sync_pad/features/auth/presentation/bloc/auth_form/auth_form_bloc.dart';
import 'package:sync_pad/features/auth/presentation/bloc/users/users_bloc.dart';
import 'package:sync_pad/injection_container.dart';

import 'domain/usecases/get_all_users.dart';

void initAuthFeature() {
  // --- Blocs ---
  sl.registerFactory(
        () => AuthBloc(
      getAuthStateChanges: sl(),
      logoutUser: sl(),
    ),
  );  sl.registerFactory(
        () => UsersBloc(
      getAllUsers: sl(),
    ),
  );
  sl.registerFactory(
        () => AuthFormBloc(
      loginUser: sl(),
      signUpUser: sl(),
      sendPasswordReset: sl(),
    ),
  );

  // --- Use Cases ---
  sl.registerLazySingleton(() => GetAuthStateChanges(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentUser(repository: sl()));
  sl.registerLazySingleton(() => LoginUser(repository: sl()));
  sl.registerLazySingleton(() => SignUpUser(repository: sl()));
  sl.registerLazySingleton(() => LogoutUser(repository: sl()));
  sl.registerLazySingleton(() => SendPasswordReset(repository: sl()));

  sl.registerLazySingleton(() => GetAllUsers(repository: sl()));


  // --- Repository ---
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Data Sources ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => FirebaseAuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
}