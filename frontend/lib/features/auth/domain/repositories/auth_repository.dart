import '../../../../core/utils/typedefs.dart';
import '../entities/user.dart';

/// Auth Repository Interface
///
/// Contract for authentication operations.
/// Implemented in data layer with Supabase.
abstract class AuthRepository {
  /// Sign in with email and password
  ResultFuture<User> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google
  ResultFuture<User> signInWithGoogle();

  /// Create new account with email and password
  ResultFuture<User> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out current user
  ResultVoid signOut();

  /// Send password reset email
  ResultVoid resetPassword(String email);

  /// Resend email verification
  ResultVoid resendVerificationEmail(String email);

  /// Get current authenticated user
  User? get currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;
}
