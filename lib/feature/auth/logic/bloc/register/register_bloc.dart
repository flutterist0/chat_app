import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test_app/feature/account/domain/repositories/account_repository.dart';
import 'package:test_app/feature/account/data/models/saved_account_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/feature/auth/domain/repositories/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;
  final AccountRepository _accountRepository;
  RegisterBloc(this._authRepository, this._accountRepository) : super(RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) async {
      emit(RegisterLoading());
      try {
        await _authRepository.signUp(event.email, event.password, event.fullName
        );
        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure(e.toString()));
      }
    });

    on<RegisterWithGoogle>((event, emit) async {
      emit(RegisterLoading());
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
        emit(RegisterGoogleSuccess());
      } catch (e) {
        emit(RegisterFailure(e.toString()));
      }
    });
  }
}