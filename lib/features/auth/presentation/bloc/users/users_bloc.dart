import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/auth/domain/usecases/get_all_users.dart';

import '../../../../../core/usecase/usecase.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetAllUsers getAllUsers;

  UsersBloc({required this.getAllUsers}) : super(UsersInitial()) {
    on<UsersEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<GetAllUsersEvent>(_onGetAlUsersEvent);
  }

  Future<void> _onGetAlUsersEvent(
    GetAllUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    final result = await getAllUsers(NoParams());

    result.fold(
      (failure) => emit(UsersFailure(failure.message ?? 'An error occurred')),
      (users) => emit(UsersLoaded(users)),
    );
  }
}
