import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/forum/bloc/forum_bloc.dart';
import 'features/forum/screens/forum_list_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(sl())..add(const CheckAuthStatus()),
        ),
        BlocProvider<ForumBloc>(
          create: (_) => ForumBloc(sl(), sl()),
        ),
      ],
      child: MaterialApp(
        title: 'UniForums',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const ForumListScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
