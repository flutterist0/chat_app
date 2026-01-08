import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:test_app/feature/auth/service/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<UserCredential> signIn(String email, String password) async {
    return await _authService.signIn(email, password);
  }

  @override
  Future<UserCredential> signUp(String email, String password, String name) async {
    return await _authService.signUp(email, password, name);
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  User? get currentUser => _authService.currentUser;
}
