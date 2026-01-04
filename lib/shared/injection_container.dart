import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/feature/auth/logic/bloc/register/register_bloc.dart';
import 'package:test_app/feature/chat/logic/bloc/chat/chat_bloc.dart';
import 'package:test_app/feature/chat/logic/bloc/chat_list/chat_list_bloc.dart';
import 'package:test_app/feature/chat/logic/bloc/search_user/search_user_bloc.dart';
import '../feature/auth/service/auth_service.dart';
import '../feature/auth/logic/bloc/login/login_bloc.dart';

final getIt = GetIt.instance;

void setupLocator() {

  getIt.registerLazySingleton<AuthService>(() => AuthService());
if (!getIt.isRegistered<FirebaseFirestore>()) {
     getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  }
  if (!getIt.isRegistered<FirebaseAuth>()) {
     getIt.registerLazySingleton(() => FirebaseAuth.instance);
  }

  getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt<AuthService>()));

  getIt.registerFactory<RegisterBloc>(() => RegisterBloc(getIt<AuthService>()));

  getIt.registerFactory<ChatListBloc>(
    () => ChatListBloc(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );
  if (!getIt.isRegistered<ImagePicker>()) {
    getIt.registerLazySingleton(() => ImagePicker());
  }

  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(
      getIt<FirebaseFirestore>(), 
      getIt<FirebaseAuth>(),
      getIt<ImagePicker>()
    ),
  );
  getIt.registerFactory<SearchUserBloc>(
    () => SearchUserBloc(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );
}