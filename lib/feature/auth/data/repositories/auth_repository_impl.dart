import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<UserCredential> signUp(
      String email, String password, String name) async {
    return await _authService.signUp(email, password, name);
  }

  @override
  Future<(UserCredential, OAuthCredential)> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  User? get currentUser => _authService.currentUser;

  @override
  Future<String> uploadProfileImage(dynamic imageFile) async {
    final user = currentUser;
    if (user == null) throw Exception("User not logged in");

    final File file = imageFile as File;
    if (!file.existsSync()) {
      throw Exception("File does not exist at path: ${file.path}");
    }

    try {
      print("Starting profile upload for User ID: ${user.uid}");
      print("File path: ${file.path}");
      print("File size: ${await file.length()} bytes");

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('${user.uid}.jpg');

      final metadata = SettableMetadata(contentType: 'image/jpeg');

      final uploadTask = storageRef.putFile(file, metadata);

      final snapshot = await uploadTask;

      print("Upload finished. State: ${snapshot.state}");
      print(
          "Transferred: ${snapshot.bytesTransferred} / ${snapshot.totalBytes}");

      if (snapshot.state == TaskState.success) {
        print("State is success. Attempting to get Download URL...");
        final downloadUrl = await storageRef.getDownloadURL();
        print("Download URL retrieved: $downloadUrl");

        await user.updatePhotoURL(downloadUrl);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'photoUrl': downloadUrl,
        });

        return downloadUrl;
      } else {
        throw Exception("Upload failed. Final state: ${snapshot.state}");
      }
    } on FirebaseException catch (e) {
      print("Firebase Exception during upload: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("General Exception during upload: $e");
      throw e;
    }
  }

  @override
  Future<void> deleteProfileImage() async {
    final user = currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('${user.uid}.jpg');
      await storageRef.delete();
    } catch (e) {
    }

    await user.updatePhotoURL(null);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'photoUrl': null,
    });
  }

  @override
  Future<void> updateProfile(
      {String? name, String? email, String? password}) async {
    final user = currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': name,
        });
      }



      if (password != null && password.isNotEmpty) {
        await user.updatePassword(password);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception("Təhlükəsizlik üçün yenidən giriş etməlisiniz.");
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Profil yenilənərkən xəta baş verdi: $e");
    }
  }
}
