import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:test_app/feature/auth/domain/repositories/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(this._authRepository) : super(LoginInitial()) {

    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

      try {
        await _authRepository.signIn(event.email, event.password);

        emit(LoginSuccess());
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}