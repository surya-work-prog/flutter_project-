import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // current user
  User? get currentUser => _auth.currentUser;

  // auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // login
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}