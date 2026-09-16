import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/default_user_seeder.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.authRepository,
    required this.seeder,
  }) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthProfileUpdated>(_onProfileUpdated);
  }

  final AuthRepository authRepository;
  final DefaultUserSeeder seeder;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(fromSplash: true));
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    try {
      await seeder.seedIfNeeded();
    } catch (_) {
      // Seeding is best-effort so splash can still continue to login.
    }

    final firebaseUser = authRepository.currentFirebaseUser;
    if (firebaseUser == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final user = await authRepository.fetchUser(firebaseUser.uid);
      emit(AuthAuthenticated(user));
    } catch (_) {
      await authRepository.logout();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.login(
        name: event.name,
        password: event.password,
        expectedRole: event.role,
      );
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthUnauthenticated(error: error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  void _onProfileUpdated(AuthProfileUpdated event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }
}
