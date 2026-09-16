part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.name,
    required this.password,
    required this.role,
  });

  final String name;
  final String password;
  final UserRole role;

  @override
  List<Object?> get props => [name, password, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthProfileUpdated extends AuthEvent {
  const AuthProfileUpdated(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}
