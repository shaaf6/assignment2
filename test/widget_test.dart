import 'package:assignment2/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_service/firebase_service.dart';

import 'package:assignment2/features/auth/bloc/auth_bloc.dart';
import 'package:assignment2/features/auth/bloc/auth_state.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([AuthService, FirestoreService])
void main() {
  late MockAuthService mockAuthService;
  setUp(() {
    mockAuthService = MockAuthService();

    // No user signed in by default
    when(mockAuthService.currentUser).thenReturn(null);
    when(mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(null));
  });

  Widget buildApp() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(mockAuthService),
        ),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  testWidgets('Login screen renders when user is unauthenticated',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.text('UniForums'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
  });

  testWidgets('Login form shows validation errors on empty submit',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    // Tap Sign In without filling form
    final signInBtn = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.tap(signInBtn);
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Login form validates email format', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).first, 'notanemail');
    final signInBtn = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.tap(signInBtn);
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('Login form validates password minimum length', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.enterText(
        find.byType(TextFormField).first, 'user@example.com');
    await tester.enterText(find.byType(TextFormField).last, '123');
    final signInBtn = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.tap(signInBtn);
    await tester.pump();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('Shows loading indicator when AuthLoading state is emitted',
      (tester) async {
    final authBloc = AuthBloc(mockAuthService);

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    authBloc.emit(const AuthLoading());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
