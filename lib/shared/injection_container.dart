import 'package:get_it/get_it.dart';
import '../feature/auth/data/auth_service.dart';
import '../feature/auth/logic/login/bloc/login_bloc.dart';

final getIt = GetIt.instance;

void setupLocator() {

  getIt.registerLazySingleton<AuthService>(() => AuthService());


  getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt<AuthService>()));
}