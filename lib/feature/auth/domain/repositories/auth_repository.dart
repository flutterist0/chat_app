import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential> signIn(String email, String password);
  Future<UserCredential> signUp(String email, String password, String name);
  Future<void> signOut();
  User? get currentUser;
}
