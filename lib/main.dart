import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/home/data/repositories/profile_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const MyApp());
}

/// Root widget that sets up BLoC providers and theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: di.sl<AuthRepository>()),
        RepositoryProvider.value(value: di.sl<ProfileRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(
              authRepository: di.sl<AuthRepository>(),
              firestore: di.sl(),
            )..add(const AuthCheckRequested()),
          ),
        ],
        child: MaterialApp(
          title: 'Profile App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routes: AppRouter.routes,
          initialRoute: AppRouter.login,
        ),
      ),
    );
  }
}
