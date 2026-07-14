import 'package:equatable/equatable.dart';

import '../data/models/user_model.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Auth is currently loading.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Sign-up succeeded — user created in Firebase Auth, needs to fill profile details.
class AuthSignUpSuccess extends AuthState {
  final String uid;
  final String email;

  const AuthSignUpSuccess({required this.uid, required this.email});

  @override
  List<Object?> get props => [uid, email];
}

/// User is fully authenticated with a complete Firestore profile.
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user.uid];
}

/// No authenticated user found.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An auth operation failed.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
