import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the user submits the sign-up form.
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Triggered when the user submits the sign-in form.
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Triggered when the user taps the logout button.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Checks current authentication state on app startup.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
