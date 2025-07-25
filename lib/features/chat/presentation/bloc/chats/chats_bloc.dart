import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/chats_entity.dart';
import '../../../domain/usecases/get_chats_use_case.dart';


part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final GetChatsForUserUseCase getChatsForUser;

  ChatsBloc({ required this.getChatsForUser})
      : super(ChatsInitial()) {
    on<ChatsEvent>((event, emit) {});

    on<GetChatsForUserEvent>(_onGetChatsForUser);
  }


  Future<void> _onGetChatsForUser(
      GetChatsForUserEvent event, Emitter<ChatsState> emit) async {
    emit(ChatsLoading());
    await emit.forEach<Either<Failure, List<ChatsEntity>>>(
      getChatsForUser(event.userId),
      onData: (result) {
        return result.fold(
          (failure) {
            return ChatsFailure(failure.message ?? 'An error occurred');
          },
          (chats) => ChatsLoaded(chats),
        );
      },
      onError: (error, stackTrace) {
        return ChatsFailure('Failed to load chats.');
      },
    );
  }
}


