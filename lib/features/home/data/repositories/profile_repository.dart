import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/data/models/user_model.dart';

/// Handles all Firestore CRUD operations for user profiles.
class ProfileRepository {
  final FirebaseFirestore firestore;

  ProfileRepository({required this.firestore});

  /// Firestore collection reference for user profiles.
  CollectionReference get _users => firestore.collection('users');

  /// Creates a new user profile document in Firestore.
  Future<void> createProfile(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  /// Retrieves a user profile document by UID.
  Future<DocumentSnapshot> getProfile(String uid) async {
    return await _users.doc(uid).get();
  }

  /// Updates an existing user profile document.
  Future<void> updateProfile(UserModel user) async {
    await _users.doc(user.uid).update(user.toMap());
  }

  /// Deletes a user profile document from Firestore.
  Future<void> deleteProfile(String uid) async {
    await _users.doc(uid).delete();
  }
}
