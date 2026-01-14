/// Base exception class for app-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(super.message, {super.code, this.statusCode});
}

/// Exception thrown when there's no network connection
class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection'])
    : super(message, code: 'NETWORK_ERROR');
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  const CacheException([String message = 'Cache operation failed'])
    : super(message, code: 'CACHE_ERROR');
}

/// Exception thrown for validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(super.message, {super.code, this.fieldErrors});
}
