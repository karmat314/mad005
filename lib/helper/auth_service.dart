import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generated with ChatGPT

  String? getUsername() {
    final user = _auth.currentUser;
    return user?.email;  // returns email (which is username in your case)
  }

  Future<String?> signInWithEmailPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success = no error message
    } on FirebaseAuthException catch (e) {
      return e.message; // failure = error message string
    }
  }

  Future<bool> registerWithEmailPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
