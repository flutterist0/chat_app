import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential> signIn(String email, String password);
  Future<UserCredential> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<String> uploadProfileImage(dynamic imageFile);
  Future<void> deleteProfileImage();
  Future<void> updateProfile({String? name, String? email, String? password});
  Future<(UserCredential, OAuthCredential)> signInWithGoogle();
  User? get currentUser;
}
