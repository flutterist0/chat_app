import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test_app/feature/auth/domain/repositories/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;
  RegisterBloc(this._authRepository) : super(RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) {
      emit(RegisterLoading());
      try {
        _authRepository.signUp(event.email, event.password, event.fullName
        );
        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure(e.toString()));
      }
    });
  }
}