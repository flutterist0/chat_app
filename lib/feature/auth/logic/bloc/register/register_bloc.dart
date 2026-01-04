import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../service/auth_service.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthService _authService;
  RegisterBloc(this._authService) : super(RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) {
      emit(RegisterLoading());
      try {
        _authService.signUp(event.email, event.password, event.fullName
        );
        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure(e.toString()));
      }
    });
  }
}