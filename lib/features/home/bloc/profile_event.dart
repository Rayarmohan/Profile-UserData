import 'package:equatable/equatable.dart';

import '../../auth/data/models/user_model.dart';

/// Base class for all profile events.
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Loads a user profile from Firestore by UID.
class LoadProfile extends ProfileEvent {
  final String uid;

  const LoadProfile({required this.uid});

  @override
  List<Object?> get props => [uid];
}

/// Updates the user profile in Firestore.
class UpdateProfile extends ProfileEvent {
  final UserModel user;

  const UpdateProfile({required this.user});

  @override
  List<Object?> get props => [user.uid];
}

/// Deletes the user profile and triggers sign-out.
class DeleteProfile extends ProfileEvent {
  final String uid;

  const DeleteProfile({required this.uid});

  @override
  List<Object?> get props => [uid];
}
