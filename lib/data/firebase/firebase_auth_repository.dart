import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../auth_repository.dart';

/// Real authentication: Firebase Auth with email/password, Google and
/// Facebook. The logic was moved here from the sign-in / sign-up screens.
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  String? get uid => _auth.currentUser?.uid;

  @override
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = _auth.currentUser!;
      if (user.emailVerified) return true;
      await user.sendEmailVerification();
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AuthFailure('No user found for that email.');
        case 'wrong-password':
        case 'invalid-credential':
          throw AuthFailure('Wrong email or password.');
        default:
          throw AuthFailure(e.message ?? 'Sign in failed. Please try again.');
      }
    }
  }

  @override
  Future<void> signUpWithEmail(
      String name, String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _auth.currentUser!.sendEmailVerification();
      await _addUserDetails(name, email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw AuthFailure('The password provided is too weak.');
        case 'email-already-in-use':
          throw AuthFailure('The account already exists for that email.');
        default:
          throw AuthFailure(e.message ?? 'Sign up failed. Please try again.');
      }
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      await _ensureUserDoc(
          googleUser.displayName ?? '', userCredential.user?.email);
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Google sign in failed.');
    } catch (e) {
      throw AuthFailure('Google sign in failed. Please try again.');
    }
  }

  @override
  Future<bool> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status != LoginStatus.success) return false;

      final OAuthCredential credential = FacebookAuthProvider.credential(
          loginResult.accessToken!.tokenString);
      final userCredential = await _auth.signInWithCredential(credential);
      await _ensureUserDoc(userCredential.user?.displayName ?? '',
          userCredential.user?.email);
      return true;
    } catch (e) {
      throw AuthFailure(
          'This email was used before with a different sign in method. '
          'Please sign in with the method you used the first time.');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Could not send the reset email.');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code == 'requires-recent-login'
          ? 'Please sign in again before changing your password.'
          : e.message ?? 'Could not update the password.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> _ensureUserDoc(String name, String? email) async {
    if (email == null) return;
    final query =
        await _db.collection('users').where('email', isEqualTo: email).get();
    if (query.docs.isEmpty) await _addUserDetails(name, email);
  }

  /// Same `users/{uid}` document the app has always written, minus the
  /// plain-text password field the first version stored.
  Future<void> _addUserDetails(String userName, String email) async {
    final user = _auth.currentUser!;
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'user_name': userName,
      'email': email,
      'phone_number': '',
      'profile_image': '',
    });
  }
}
