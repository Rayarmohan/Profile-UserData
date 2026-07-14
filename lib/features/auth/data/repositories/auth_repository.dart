import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Handles all Firebase Authentication operations.
class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.firebaseAuth, required this.firestore});

  /// Returns the currently signed-in Firebase user, or null.
  User? get currentUser => firebaseAuth.currentUser;

  /// Stream that emits the auth state whenever a user signs in or out.
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  /// Registers a new user with email and password.
  /// Returns the Firebase [User] on success.
  /// Throws if the email is already in use.
  Future<User> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) throw Exception('Sign up failed: no user returned.');
    return user;
  }

  /// Signs in an existing user with email and password.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) throw Exception('Sign in failed: no user returned.');

    // Fetch profile from Firestore.
    final doc = await firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      // Auth user exists but no Firestore profile yet.
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        createdAt: DateTime.now(),
      );
      await firestore.collection('users').doc(user.uid).set(userModel.toMap());
      return userModel;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
