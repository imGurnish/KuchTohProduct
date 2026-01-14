import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'desktop_oauth_helper.dart';

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

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

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
  GoogleSignIn? _googleSignIn;

  AuthRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Check if running on desktop (Windows, Linux, macOS)
  bool get _isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  /// Lazy initialization of GoogleSignIn (for mobile platforms)
  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn(
      clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      scopes: ['email', 'profile', 'openid'],
    );
    return _googleSignIn!;
  }

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
  Future<UserModel> signInWithGoogle() async {
    if (kIsWeb || _isDesktop) {
      // For Web and Desktop: Use Supabase's native OAuth flow
      return await _signInWithGoogleOAuth();
    } else {
      // For Mobile (Android/iOS): Use google_sign_in package
      return await _signInWithGoogleMobile();
    }
  }

  /// Google Sign In using Supabase OAuth (for Web and Desktop)
  Future<UserModel> _signInWithGoogleOAuth() async {
    if (_isDesktop) {
      // Desktop (Windows/Linux/macOS): Use local callback server
      return await _signInWithGoogleDesktop();
    }

    // For Web: Use Supabase's signInWithOAuth - this redirects the page
    await _supabaseClient.auth.signInWithOAuth(OAuthProvider.google);

    // Note: This will redirect the page. After redirect back,
    // the auth state listener will pick up the session.
    throw AuthException('Redirecting to Google...');
  }

  /// Google Sign In for Desktop using local callback server
  Future<UserModel> _signInWithGoogleDesktop() async {
    final helper = DesktopOAuthHelper(supabaseClient: _supabaseClient);
    final response = await helper.signInWithGoogle();

    if (response.user == null) {
      throw AuthException('Google sign in failed');
    }

    return UserModel.fromSupabaseUser(response.user!);
  }

  /// Google Sign In for Mobile using google_sign_in package
  Future<UserModel> _signInWithGoogleMobile() async {
    final clientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    if (clientId == null || clientId.isEmpty) {
      throw AuthException(
        'Google Sign In not configured. Please add GOOGLE_WEB_CLIENT_ID to .env',
      );
    }

    // Trigger Google Sign In flow
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthException('Google sign in was cancelled');
    }

    // Get auth tokens
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw AuthException('No ID token found. Please try again.');
    }

    // Sign in to Supabase with Google ID token
    final response = await _supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    if (response.user == null) {
      throw AuthException('Google sign in failed');
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
    try {
      await googleSignIn.signOut();
    } catch (_) {
      // Ignore if Google Sign In wasn't initialized
    }
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
