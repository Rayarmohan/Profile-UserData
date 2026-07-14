import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/profile_repository.dart';
import '../../auth/data/models/user_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Manages profile CRUD state (load, update, delete) for the home/profile screens.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<DeleteProfile>(_onDeleteProfile);
  }

  /// Fetches user profile from Firestore.
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final doc = await profileRepository.getProfile(event.uid);
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        emit(ProfileLoaded(user: user));
      } else {
        emit(const ProfileError(message: 'Profile not found.'));
      }
    } catch (e) {
      emit(ProfileError(message: 'Failed to load profile: $e'));
    }
  }

  /// Updates user profile in Firestore and reloads state.
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await profileRepository.updateProfile(event.user);
      emit(ProfileLoaded(user: event.user));
    } catch (e) {
      emit(ProfileError(message: 'Failed to update profile: $e'));
    }
  }

  /// Deletes user profile from Firestore.
  Future<void> _onDeleteProfile(
    DeleteProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await profileRepository.deleteProfile(event.uid);
      emit(const ProfileDeleted());
    } catch (e) {
      emit(ProfileError(message: 'Failed to delete profile: $e'));
    }
  }
}
