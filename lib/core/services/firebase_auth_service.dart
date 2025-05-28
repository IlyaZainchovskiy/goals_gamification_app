import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:goals_gamification_app/core/models/user.dart';
import 'package:goals_gamification_app/data/repositories/user_repository.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final UserRepository _userRepository;

  FirebaseAuthService(this._userRepository);

  firebase_auth.User? get currentUser => _auth.currentUser;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<firebase_auth.UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? email,
          username: username,
          level: 1,
          xp: 0,
          achievements: [],
        );

        await _userRepository.createUser(newUser);
      }

      return credential;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }


  Future<firebase_auth.UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }


  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
}
