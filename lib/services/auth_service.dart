import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  static Future<User?> signUpWithEmail(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  static Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  static String friendlyError(String code) {
    const map = {
      'user-not-found': 'No account with this email.',
      'wrong-password': 'Incorrect password.',
      'invalid-credential': 'Invalid email or password.',
      'email-already-in-use': 'Email already registered.',
      'invalid-email': 'Invalid email address.',
      'weak-password': 'Password too weak (min 6 chars).',
      'popup-closed-by-user': 'Sign-in window was closed. Try again.',
      'network-request-failed': 'Network error. Check connection.',
      'too-many-requests': 'Too many attempts. Try later.',
    };
    return map[code] ?? 'Sign-in failed. Try again.';
  }
}
