import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:test_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:test_app/feature/account/data/models/saved_account_model.dart';
import 'package:test_app/feature/account/domain/repositories/account_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  final AccountRepository _accountRepository;

  LoginBloc(this._authRepository, this._accountRepository) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithGoogle>(_onLoginWithGoogle);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      await _authRepository.signIn(event.email, event.password);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
         await _accountRepository.saveAccount(SavedAccountModel(
           uid: user.uid,
           email: user.email ?? event.email,
           password: event.password,
           displayName: user.displayName ?? user.email?.split('@')[0] ?? 'User',
           photoUrl: user.photoURL,
         ));
      }

      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogle event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final (UserCredential userCredential, OAuthCredential credential) = await _authRepository.signInWithGoogle();
      final user = userCredential.user;
      
      if (user != null) {
        await _accountRepository.saveAccount(SavedAccountModel(
          uid: user.uid,
          email: user.email ?? '',
          password: '',
          displayName: user.displayName ?? 'Google User',
          photoUrl: user.photoURL,
          accessToken: credential.accessToken,
          idToken: credential.idToken,
        ));
      }
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString().replaceAll("Exception: ", "")));
    }
  }
}