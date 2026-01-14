import 'package:get_it/get_it.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
/// Call this before runApp() in main.dart
Future<void> initDependencies() async {
  // ============================================
  // EXTERNAL DEPENDENCIES
  // ============================================
  // TODO: Initialize Supabase client
  // final supabase = await Supabase.initialize(
  //   url: dotenv.env['SUPABASE_URL']!,
  //   anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  // );
  // sl.registerLazySingleton(() => supabase.client);

  // ============================================
  // DATA SOURCES
  // ============================================
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(sl()),
  // );

  // ============================================
  // REPOSITORIES
  // ============================================
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(sl()),
  // );

  // ============================================
  // USE CASES
  // ============================================
  // sl.registerLazySingleton(() => SignInWithEmail(sl()));
  // sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  // sl.registerLazySingleton(() => SignUp(sl()));
  // sl.registerLazySingleton(() => SignOut(sl()));
  // sl.registerLazySingleton(() => ResetPassword(sl()));

  // ============================================
  // BLOCS
  // ============================================
  // sl.registerFactory(() => AuthBloc(
  //   signInWithEmail: sl(),
  //   signInWithGoogle: sl(),
  //   signUp: sl(),
  //   signOut: sl(),
  //   resetPassword: sl(),
  // ));
}
