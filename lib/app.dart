import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/fee/fee_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/models/app_user.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/fee_repository.dart';
import 'data/services/default_user_seeder.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/school/school_home_screen.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/student/student_home_screen.dart';

class IqNavigatorApp extends StatelessWidget {
  const IqNavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => FeeRepository()),
        RepositoryProvider(create: (_) => DefaultUserSeeder()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              seeder: context.read<DefaultUserSeeder>(),
            )..add(const AuthStarted()),
          ),
          BlocProvider(
            create: (context) => FeeBloc(
              feeRepository: context.read<FeeRepository>(),
            ),
          ),
        ],
        child: ResponsiveSizer(
          builder: (context, orientation, screenType) {
            return MaterialApp(
              title: 'IQ Navigator',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              home: const _AuthGate(),
            );
          },
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.role == UserRole.school) {
            return SchoolHomeScreen(user: state.user);
          }
          return StudentHomeScreen(user: state.user);
        }
        if (state is AuthInitial ||
            (state is AuthLoading && state.fromSplash)) {
          return const SplashScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
