import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential?> signInWithGoogle();
  Future<UserCredential> registerWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}
