import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'auth_exception.dart';
import 'auth_service.dart';

class FirebaseAuthServiceImpl implements AuthService {
  final FirebaseAuth _auth;

  FirebaseAuthServiceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<UserModel?> get authStateChanges => _auth
      .authStateChanges()
      .map((user) => user == null ? null : UserModel.fromFirebaseUser(user));

  @override
  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        code: e.code,
        message: _mapError(e.code),
      );
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.updateDisplayName(name.trim());
      await credential.user!.reload();
      return UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: name.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        code: e.code,
        message: _mapError(e.code),
      );
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
