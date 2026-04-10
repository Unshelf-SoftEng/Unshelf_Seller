import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:unshelf_seller/core/errors/app_exceptions.dart';
import 'package:unshelf_seller/core/interfaces/i_auth_service.dart';
import 'package:unshelf_seller/core/logger.dart';

class AuthService implements IAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: dotenv.env['GOOGLE_CLIENT_ID']!,
              scopes: <String>['email', 'profile'],
            );

  @override
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Sign in failed', e, stackTrace);
      throw AuthException(e.message ?? 'Sign in failed',
          code: e.code, originalError: e);
    }
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Google sign in failed', e, stackTrace);
      throw AuthException(e.message ?? 'Google sign in failed',
          code: e.code, originalError: e);
    }
  }

  @override
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Registration failed', e, stackTrace);
      throw AuthException(e.message ?? 'Registration failed',
          code: e.code, originalError: e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Failed to send password reset email', e, stackTrace);
      throw AuthException(e.message ?? 'Failed to send password reset email',
          code: e.code, originalError: e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      AppLogger.info('User signing out');
      await _auth.signOut();
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Sign out failed', e, stackTrace);
      throw AuthException(e.message ?? 'Sign out failed',
          code: e.code, originalError: e);
    }
  }
}
