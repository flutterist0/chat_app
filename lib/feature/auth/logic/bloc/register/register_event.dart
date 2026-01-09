part of 'register_bloc.dart';

@immutable
abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final String fullName;
  final String email;
  final String password;

  RegisterSubmitted({required this.fullName, required this.email, required this.password});
}

class RegisterWithGoogle extends RegisterEvent {}