import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Files feature
import '../../features/files/data/datasources/files_local_data_source.dart';
import '../../features/files/data/repositories/files_repository_impl.dart';
import '../../features/files/domain/repositories/files_repository.dart';
import '../../features/files/presentation/bloc/files_bloc.dart';

// Chat feature
import '../../features/chat/data/datasources/chat_local_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

/// GetIt service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // ============================================
  // EXTERNAL
  // ============================================
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ============================================
  // AUTH FEATURE
  // ============================================
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );

  // Blocs
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));

  // ============================================
  // FILES FEATURE
  // ============================================
  // Data sources
  sl.registerLazySingleton<FilesLocalDataSource>(
    () => FilesLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<FilesRepository>(
    () => FilesRepositoryImpl(dataSource: sl()),
  );

  // Blocs
  sl.registerFactory<FilesBloc>(() => FilesBloc(filesRepository: sl()));

  // ============================================
  // CHAT FEATURE
  // ============================================
  // Data sources
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(dataSource: sl()),
  );

  // Blocs
  sl.registerFactory<ChatBloc>(() => ChatBloc(chatRepository: sl()));
}

/// Get instance from service locator
T getIt<T extends Object>() => sl<T>();
