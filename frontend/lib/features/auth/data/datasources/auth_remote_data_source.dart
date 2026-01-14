import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Auth Remote Data Source
///
/// Handles all remote authentication operations via Supabase.
abstract class AuthRemoteDataSource {
  /// Get current user
  UserModel? get currentUser;

  /// Stream of auth state changes
  Stream<UserModel?> get authStateChanges;

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Resend verification email
  Future<void> resendVerificationEmail(String email);
}

/// Supabase implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  UserModel? get currentUser {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw AuthException('Sign in failed');
    }

    return UserModel.fromSupabaseUser(response.user!);
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );

    if (response.user == null) {
      throw AuthException('Sign up failed');
    }

    return UserModel.fromSupabaseUser(response.user!);
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await _supabaseClient.auth.resend(type: OtpType.signup, email: email);
  }
}
