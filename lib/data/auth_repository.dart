/// Authentication seam: Firebase Auth in the real build, a local session in
/// demo mode.
abstract class AuthRepository {
  bool get isSignedIn;
  String? get uid;

  /// Returns `false` when the account exists but the email is not verified
  /// yet (a verification email has been sent).
  Future<bool> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String name, String email, String password);

  /// Return `false` when the user cancelled the provider dialog.
  Future<bool> signInWithGoogle();
  Future<bool> signInWithFacebook();

  Future<void> sendPasswordReset(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> signOut();
}

class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}
