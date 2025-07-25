import 'package:get_it/get_it.dart';
import 'package:sync_pad/features/chat/domain/usecases/send_document_message_use_case.dart';
import 'package:sync_pad/features/chat/domain/usecases/send_system_message_use_case.dart';
import 'package:sync_pad/features/chat/presentation/bloc/chat_details/chat_details_bloc.dart';
import 'package:sync_pad/features/chat/presentation/bloc/chats/chats_bloc.dart';
import 'package:sync_pad/features/chat/presentation/bloc/messages/messages_bloc.dart';
import 'package:sync_pad/features/chat/presentation/bloc/read_message/read_message_bloc.dart';
import 'package:sync_pad/features/chat/presentation/bloc/send_message/send_message_bloc.dart';

import 'data/datasources/chats_remote_data_source.dart';
import 'data/datasources/message_remote_data_source.dart';
import 'data/repositories/chats_repository_impl.dart';
import 'data/repositories/message_repository_impl.dart';
import 'domain/repositories/chats_repository.dart';
import 'domain/repositories/message_repository.dart';
import 'domain/usecases/check_create_chat_use_case.dart';
import 'domain/usecases/get_chats_use_case.dart';
import 'domain/usecases/get_messages_use_case.dart';
import 'domain/usecases/read_messages_use_case.dart';
import 'domain/usecases/send_image_message_use_case.dart';
import 'domain/usecases/send_text_message_use_case.dart';

final sl = GetIt.instance;

void initChatFeature() {
  /// Chat Use Cases Injection

  sl.registerLazySingleton<CheckOrCreateChatUseCase>(
    () => CheckOrCreateChatUseCase(repository: sl.call()),
  );
  sl.registerLazySingleton<GetChatsForUserUseCase>(
    () => GetChatsForUserUseCase(repository: sl.call()),
  );

  /// Chat Repository Injection
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl.call()),
  );

  /// Chat Data sources Injection
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl.call()),
  );

  /// Chat Bloc Injection
  sl.registerFactory(() => ChatDetailsBloc(checkOrCreateChat: sl.call()));
  sl.registerFactory(() => ChatsBloc(getChatsForUser: sl.call()));

  /// Messages Use Cases Injection
  sl.registerLazySingleton<GetMessagesUseCase>(
    () => GetMessagesUseCase(repository: sl.call()),
  );
  sl.registerLazySingleton<SendTextMessageUseCase>(
    () => SendTextMessageUseCase(repository: sl.call()),
  );
  sl.registerLazySingleton<SendImageMessageUseCase>(
    () => SendImageMessageUseCase(repository: sl.call()),
  );

  sl.registerLazySingleton<SendDocumentMessageUseCase>(
    () => SendDocumentMessageUseCase(repository: sl.call()),
  );

  sl.registerLazySingleton<SendSystemMessageUseCase>(
    () => SendSystemMessageUseCase(repository: sl.call()),
  );

  sl.registerLazySingleton<ReadMessagesUseCase>(
    () => ReadMessagesUseCase(repository: sl.call()),
  );

  /// Messages Repository Injection
  sl.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(remoteDataSource: sl.call()),
  );

  /// Messages Data sources Injection
  sl.registerLazySingleton<MessageRemoteDataSource>(
    () => MessageRemoteDataSourceImpl(
      firestore: sl.call(),
      firebaseStorage: sl.call(),
    ),
  );

  /// Messages Bloc Injection
  sl.registerFactory(() => MessagesBloc(getMessagesUseCase: sl.call()));
  sl.registerFactory(() => ReadMessageBloc(readMessagesUseCase: sl.call()));
  sl.registerFactory(
    () => SendMessageBloc(
      sendTextMessageUseCase: sl.call(),
      sendImageMessageUseCase: sl.call(),
      sendDocumentMessageUseCase: sl.call(),
      sendSystemMessageUseCase: sl(),
    ),
  );
}
