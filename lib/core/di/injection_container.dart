import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/home/data/repositories/profile_repository.dart';

/// Service locator instance for dependency injection.
final sl = GetIt.instance;

/// Initializes all dependencies that can be resolved immediately.
/// Must be called before runApp() inside main().
Future<void> init() async {
  // External dependencies
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Repositories
  sl.registerLazySingleton(() => AuthRepository(firebaseAuth: sl(), firestore: sl()));
  sl.registerLazySingleton(() => ProfileRepository(firestore: sl()));
}
