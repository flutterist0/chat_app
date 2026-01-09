import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).update({
          'isOnline': true,
        });
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<UserCredential> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        await result.user!.reload();

        await _firestore.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
          'photoUrl': '',
        });
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<(UserCredential, OAuthCredential)> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(code: 'aborted', message: 'Giriş ləğv edildi');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);

      if (result.user != null) {
        final userDoc = await _firestore.collection('users').doc(result.user!.uid).get();
        if (!userDoc.exists) {
           await _firestore.collection('users').doc(result.user!.uid).set({
            'uid': result.user!.uid,
            'name': result.user!.displayName ?? 'İstifadəçi',
            'email': result.user!.email,
            'createdAt': FieldValue.serverTimestamp(),
            'isOnline': true,
            'lastSeen': FieldValue.serverTimestamp(),
            'photoUrl': result.user!.photoURL,
          });
        } else {
             await _firestore.collection('users').doc(result.user!.uid).update({
            'isOnline': true,
          });
        }
      }
      return (result, credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw FirebaseAuthException(code: 'unknown', message: e.toString());
    }
  }

  Future<UserCredential?> signInWithGoogleSilently() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signInSilently();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      
      if (result.user != null) {
         await _firestore.collection('users').doc(result.user!.uid).update({
            'isOnline': true,
          });
      }
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogleTokens(String accessToken, String idToken) async {
    try {
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      final UserCredential result = await _auth.signInWithCredential(credential);
      
      if (result.user != null) {
         await _firestore.collection('users').doc(result.user!.uid).update({
            'isOnline': true,
          });
      }
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut({bool disconnectGoogle = true}) async {
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
    try {
      if (disconnectGoogle) {
        await GoogleSignIn().disconnect();
      } else {
        await GoogleSignIn().signOut();
      }
    } catch (e) {
    }
    await _auth.signOut();
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu email ilə istifadəçi tapılmadı.';
      case 'wrong-password':
        return 'Şifrə yanlışdır.';
      case 'email-already-in-use':
        return 'Bu email artıq qeydiyyatdan keçib.';
      case 'invalid-email':
        return 'Email formatı düzgün deyil.';
      case 'weak-password':
        return 'Şifrə çox zəifdir.';
      case 'network-request-failed':
        return 'İnternet bağlantısını yoxlayın.';
      default:
        return 'Xəta baş verdi: ${e.message}';
    }
  }
}