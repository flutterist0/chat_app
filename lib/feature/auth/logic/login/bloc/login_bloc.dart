import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/auth_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;

  LoginBloc(this._authService) : super(LoginInitial()) {

    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

      try {
        await _authService.signIn(event.email, event.password);

        emit(LoginSuccess());
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}