import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Handles authentication logic for sign-in, sign-up, sign-out, and
/// initial auth state checks.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final FirebaseFirestore firestore;

  AuthBloc({required this.authRepository, required this.firestore})
      : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  /// Checks if a user is already signed in on app startup.
  /// If they have a complete profile → AuthAuthenticated.
  /// If they just signed up but have no profile → AuthSignUpSuccess.
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = authRepository.currentUser;
    if (user != null) {
      // Check Firestore profile completeness.
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final userModel = UserModel.fromMap(data);

        // Check if profile details are filled (firstName is a good indicator).
        if (userModel.firstName.isNotEmpty) {
          emit(AuthAuthenticated(user: userModel));
        } else {
          // Profile exists but details not filled yet.
          emit(AuthSignUpSuccess(uid: user.uid, email: user.email ?? ''));
        }
      } else {
        // No Firestore doc — treat as fresh signup.
        emit(AuthSignUpSuccess(uid: user.uid, email: user.email ?? ''));
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handles email/password sign-in.
  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final userModel = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: userModel));
    } on Exception catch (e) {
      emit(AuthError(message: _mapAuthError(e)));
    }
  }

  /// Handles new user registration — creates Firebase Auth account only.
  /// If email already exists, Firebase throws email-already-in-use.
  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      emit(AuthSignUpSuccess(uid: user.uid, email: user.email ?? ''));
    } on Exception catch (e) {
      emit(AuthError(message: _mapAuthError(e)));
    }
  }

  /// Handles user sign-out.
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  /// Maps Firebase auth exceptions to user-friendly messages.
  String _mapAuthError(Exception e) {
    final msg = e.toString();
    if (msg.contains('user-not-found')) {
      return 'No user found with this email.';
    } else if (msg.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (msg.contains('email-already-in-use')) {
      return 'User already exists. Please go to login.';
    } else if (msg.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (msg.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
