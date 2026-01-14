import 'package:equatable/equatable.dart';

/// Base failure class for domain layer error handling
/// Uses Equatable for value equality comparison
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure for authentication-related errors
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  // Common auth failure factories
  factory AuthFailure.invalidCredentials() => const AuthFailure(
    'Invalid email or password',
    code: 'INVALID_CREDENTIALS',
  );

  factory AuthFailure.emailNotVerified() =>
      const AuthFailure('Please verify your email', code: 'EMAIL_NOT_VERIFIED');

  factory AuthFailure.userNotFound() => const AuthFailure(
    'No account found with this email',
    code: 'USER_NOT_FOUND',
  );

  factory AuthFailure.emailAlreadyInUse() =>
      const AuthFailure('Email is already registered', code: 'EMAIL_IN_USE');

  factory AuthFailure.weakPassword() =>
      const AuthFailure('Password is too weak', code: 'WEAK_PASSWORD');

  factory AuthFailure.googleSignInCancelled() => const AuthFailure(
    'Google sign-in was cancelled',
    code: 'GOOGLE_CANCELLED',
  );

  factory AuthFailure.sessionExpired() => const AuthFailure(
    'Session expired, please sign in again',
    code: 'SESSION_EXPIRED',
  );
}

/// Failure for server-related errors
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {super.code, this.statusCode});

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure for network-related errors
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
    : super(message, code: 'NETWORK_ERROR');
}

/// Failure for cache-related errors
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache operation failed'])
    : super(message, code: 'CACHE_ERROR');
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(super.message, {super.code, this.fieldErrors});

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Failure for unexpected/unknown errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String message = 'An unexpected error occurred'])
    : super(message, code: 'UNEXPECTED_ERROR');
}
