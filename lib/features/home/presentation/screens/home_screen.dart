import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

/// Home screen that displays the logged-in user's full profile and logout button.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileDeleted) {
            context.read<AuthBloc>().add(const AuthSignOutRequested());
            Navigator.pushReplacementNamed(context, AppRouter.login);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        context
                            .read<ProfileBloc>()
                            .add(LoadProfile(uid: authState.user.uid));
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(LoadProfile(uid: user.uid));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // User avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        user.firstName.isNotEmpty
                            ? user.firstName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User name
                    Text(
                      user.fullName.isNotEmpty ? user.fullName : 'No Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile details section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Profile Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.person_outline,
                      label: 'First Name',
                      value:
                          user.firstName.isNotEmpty ? user.firstName : 'Not provided',
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      icon: Icons.person_outline,
                      label: 'Last Name',
                      value:
                          user.lastName.isNotEmpty ? user.lastName : 'Not provided',
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email,
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      icon: Icons.calendar_today,
                      label: 'Date of Birth',
                      value: user.dateOfBirth.isNotEmpty
                          ? user.dateOfBirth
                          : 'Not provided',
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      icon: Icons.wc_outlined,
                      label: 'Gender',
                      value:
                          user.gender.isNotEmpty ? user.gender : 'Not provided',
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      icon: Icons.flag_outlined,
                      label: 'Nationality',
                      value: user.nationality.isNotEmpty
                          ? user.nationality
                          : 'Not provided',
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      icon: Icons.language,
                      label: 'Language Spoken',
                      value: user.languageSpoken.isNotEmpty
                          ? user.languageSpoken
                          : 'Not provided',
                    ),
                    const SizedBox(height: 24),

                    // Edit profile button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ProfileBloc>(),
                                child: const ProfileScreen(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
              Navigator.pushReplacementNamed(context, AppRouter.login);
            },
            child: const Text('Logout',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
