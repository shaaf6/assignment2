import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_service/src/auth/auth_exception.dart';
import 'package:firebase_service/src/auth/firebase_auth_service.dart';
import 'package:firebase_service/src/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  late MockFirebaseAuth mockAuth;
  late FirebaseAuthServiceImpl authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    authService = FirebaseAuthServiceImpl(auth: mockAuth);
  });

  group('signIn', () {
    test('returns UserModel on success', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockUser.uid).thenReturn('uid-001');
      when(mockUser.email).thenReturn('alice@example.com');
      when(mockUser.displayName).thenReturn('Alice');
      when(mockCredential.user).thenReturn(mockUser);
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockCredential);

      final result = await authService.signIn(
        email: 'alice@example.com',
        password: 'secret123',
      );

      expect(result, isA<UserModel>());
      expect(result.uid, 'uid-001');
      expect(result.email, 'alice@example.com');
      expect(result.displayName, 'Alice');
    });

    test('throws AuthException on FirebaseAuthException', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(
        () => authService.signIn(email: 'x@x.com', password: 'pass'),
        throwsA(isA<AuthException>()),
      );
    });

    test('AuthException has user-friendly message for wrong-password', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      try {
        await authService.signIn(email: 'x@x.com', password: 'bad');
        fail('Expected AuthException');
      } on AuthException catch (e) {
        expect(e.message, contains('Incorrect'));
      }
    });
  });

  group('signOut', () {
    test('calls FirebaseAuth.signOut', () async {
      when(mockAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(mockAuth.signOut()).called(1);
    });
  });

  group('authStateChanges', () {
    test('emits null when no user is signed in', () {
      when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));

      expect(authService.authStateChanges, emits(isNull));
    });

    test('emits UserModel when user is signed in', () {
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('uid-002');
      when(mockUser.email).thenReturn('bob@example.com');
      when(mockUser.displayName).thenReturn('Bob');
      when(mockAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(mockUser));

      expect(authService.authStateChanges, emits(isA<UserModel>()));
    });
  });

  group('currentUser', () {
    test('returns null when no user', () {
      when(mockAuth.currentUser).thenReturn(null);
      expect(authService.currentUser, isNull);
    });

    test('returns UserModel when user is logged in', () {
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('uid-003');
      when(mockUser.email).thenReturn('carol@example.com');
      when(mockUser.displayName).thenReturn('Carol');
      when(mockAuth.currentUser).thenReturn(mockUser);

      expect(authService.currentUser, isA<UserModel>());
    });
  });
}
