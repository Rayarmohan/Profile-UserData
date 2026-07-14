import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_details_screen.dart';

/// Centralized route definitions and navigation helper.
class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profileDetails = '/profile-details';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        signup: (_) => const SignupScreen(),
        home: (_) => const HomeScreen(),
        profileDetails: (_) => const ProfileDetailsScreen(),
        profile: (_) => const ProfileScreen(),
      };
}
