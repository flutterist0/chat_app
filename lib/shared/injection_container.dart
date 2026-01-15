import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/feature/auth/logic/bloc/login/login_bloc.dart';
import 'package:test_app/feature/auth/service/auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/feature/auth/logic/bloc/register/register_bloc.dart';
import 'package:test_app/feature/chat/logic/bloc/chat/chat_bloc.dart';
import 'package:test_app/feature/chat/logic/bloc/chat_list/chat_list_bloc.dart';
import 'package:test_app/feature/chat/data/repositories/chat_repository_impl.dart';
import 'package:test_app/feature/chat/domain/repositories/chat_repository.dart';
import 'package:test_app/feature/chat/logic/bloc/search_user/search_user_bloc.dart';
import 'package:test_app/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:test_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:test_app/feature/notification/data/repositories/notification_repository_impl.dart';
import 'package:test_app/feature/notification/domain/repositories/notification_repository.dart';

import 'package:test_app/feature/notification/logic/bloc/notification_bloc.dart';
import 'package:test_app/feature/chat/service/chat_service.dart';
import 'package:test_app/feature/notification/services/notification_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test_app/feature/account/data/repositories/account_repository_impl.dart';
import 'package:test_app/feature/account/domain/repositories/account_repository.dart';
import 'package:test_app/feature/account/logic/bloc/account_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/feature/settings/data/repositories/settings_repository_impl.dart';
import 'package:test_app/feature/settings/domain/repositories/settings_repository.dart';
import 'package:test_app/feature/settings/logic/bloc/settings_bloc.dart';
import 'package:test_app/feature/chat/service/friendship_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<AuthService>()));
  getIt.registerLazySingleton<ChatService>(() => ChatService());
  getIt.registerLazySingleton<FriendshipService>(() => FriendshipService(getIt(), getIt()));
  if (!getIt.isRegistered<FirebaseFirestore>()) {
     getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  }
  if (!getIt.isRegistered<FirebaseAuth>()) {
     getIt.registerLazySingleton(() => FirebaseAuth.instance);
  }

  getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt<AuthRepository>(), getIt<AccountRepository>()));

  getIt.registerFactory<RegisterBloc>(() => RegisterBloc(getIt<AuthRepository>(), getIt<AccountRepository>()));

  getIt.registerFactory<ChatListBloc>(
    () => ChatListBloc(getIt<ChatRepository>(), getIt<FirebaseAuth>()),
  );

  if (!getIt.isRegistered<ImagePicker>()) {
    getIt.registerLazySingleton(() => ImagePicker());
  }

  getIt.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(getIt<ChatService>(), getIt<ImagePicker>()));

  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(
      getIt<ChatRepository>(), 
      getIt<FirebaseAuth>(),
    ),
  );
  getIt.registerFactory<SearchUserBloc>(
    () => SearchUserBloc(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(getIt<FirebaseFirestore>()));
  getIt.registerFactory<NotificationBloc>(() => NotificationBloc(getIt<NotificationRepository>()));

  getIt.registerLazySingleton(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(getIt<FlutterSecureStorage>(), getIt<AuthService>()));
  getIt.registerFactory<AccountBloc>(() => AccountBloc(getIt<AccountRepository>(), getIt<FirebaseAuth>()));

  getIt.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(getIt<SharedPreferences>()));
  getIt.registerFactory<SettingsBloc>(() => SettingsBloc(getIt<SettingsRepository>(), getIt<AuthRepository>()));
}