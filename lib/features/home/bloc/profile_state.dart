import 'package:equatable/equatable.dart';

import '../../auth/data/models/user_model.dart';

/// Base class for all profile states.
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any profile load.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Profile is currently loading.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile loaded successfully.
class ProfileLoaded extends ProfileState {
  final UserModel user;

  const ProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user.uid];
}

/// Profile operation failed.
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Profile deleted successfully.
class ProfileDeleted extends ProfileState {
  const ProfileDeleted();
}
