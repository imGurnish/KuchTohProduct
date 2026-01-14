# Authentication Implementation Guide

## File-by-File Implementation

---

## Domain Layer

### User Entity
**File**: `lib/features/auth/domain/entities/user.dart`

The core business model for authenticated users:

```dart
class User extends Equatable {
  final String id;
  final String email;
  final bool emailVerified;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.emailVerified,
    this.displayName,
    this.avatarUrl,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, emailVerified, displayName, avatarUrl, createdAt];
}
```

### Auth Repository Interface
**File**: `lib/features/auth/domain/repositories/auth_repository.dart`

Abstract contract for all auth operations:

```dart
abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;

  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, User>> signInWithGoogle();
  
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> resendVerificationEmail(String email);
}
```

---

## Data Layer

### User Model
**File**: `lib/features/auth/data/models/user_model.dart`

Converts Supabase User to domain User:

```dart
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.emailVerified,
    super.displayName,
    super.avatarUrl,
    super.createdAt,
  });

  factory UserModel.fromSupabaseUser(supabase.User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      emailVerified: user.emailConfirmedAt != null,
      displayName: user.userMetadata?['display_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
    );
  }
}
```

### Auth Remote Data Source
**File**: `lib/features/auth/data/datasources/auth_remote_data_source.dart`

Direct Supabase API integration with platform-specific Google Sign In:

```dart
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  // Platform detection
  bool get _isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    if (kIsWeb || _isDesktop) {
      return await _signInWithGoogleOAuth();
    } else {
      return await _signInWithGoogleMobile();
    }
  }

  // Web/Desktop: Supabase OAuth
  Future<UserModel> _signInWithGoogleOAuth() async {
    if (_isDesktop) {
      return await _signInWithGoogleDesktop();
    }
    await _supabaseClient.auth.signInWithOAuth(OAuthProvider.google);
    throw AuthException('Redirecting to Google...');
  }

  // Mobile: google_sign_in package
  Future<UserModel> _signInWithGoogleMobile() async {
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    
    final response = await _supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
    
    return UserModel.fromSupabaseUser(response.user!);
  }
}
```

### Desktop OAuth Helper
**File**: `lib/features/auth/data/datasources/desktop_oauth_helper.dart`

Handles OAuth on Windows/Linux using local HTTP server:

```dart
class DesktopOAuthHelper {
  static const int _callbackPort = 8585;
  
  Future<AuthResponse> signInWithGoogle() async {
    // 1. Start local HTTP server on port 8585
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, _callbackPort);
    
    // 2. Get OAuth URL with Supabase's internal PKCE
    final oauthResponse = await _supabaseClient.auth.getOAuthSignInUrl(
      provider: OAuthProvider.google,
      redirectTo: 'http://localhost:$_callbackPort/auth/callback',
    );
    
    // 3. Open browser
    await launchUrl(Uri.parse(oauthResponse.url));
    
    // 4. Listen for callback with auth code
    _server!.listen((request) async {
      final code = request.requestedUri.queryParameters['code'];
      await _supabaseClient.auth.exchangeCodeForSession(code!);
      // Return auth response
    });
  }
}
```

### Auth Repository Implementation
**File**: `lib/features/auth/data/repositories/auth_repository_impl.dart`

Wraps data source with error handling:

```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

---

## Presentation Layer

### Auth Bloc
**File**: `lib/features/auth/presentation/bloc/auth_bloc.dart`

Manages authentication state:

#### Events

| Event | Description |
|-------|-------------|
| `AuthCheckRequested` | Check current auth status |
| `AuthSignInRequested` | Email/password sign in |
| `AuthSignUpRequested` | Register new user |
| `AuthGoogleSignInRequested` | Google OAuth sign in |
| `AuthSignOutRequested` | Sign out user |
| `AuthPasswordResetRequested` | Send password reset email |
| `AuthResendVerificationRequested` | Resend verification email |

#### States

| State | Description |
|-------|-------------|
| `AuthInitial` | Initial state |
| `AuthLoading` | Operation in progress |
| `AuthAuthenticated(user)` | User is signed in |
| `AuthUnauthenticated` | No user signed in |
| `AuthNeedsVerification(email)` | Awaiting email verification |
| `AuthPasswordResetSent(email)` | Reset email sent |
| `AuthError(message)` | Error occurred |

#### Key Handler: Google Sign In

```dart
Future<void> _onGoogleSignInRequested(
  AuthGoogleSignInRequested event,
  Emitter<AuthState> emit,
) async {
  emit(const AuthLoading());

  final result = await _authRepository.signInWithGoogle();

  result.fold(
    (failure) {
      // Ignore redirect messages on web
      if (!failure.message.contains('Redirecting')) {
        emit(AuthError(failure.message));
      }
    },
    (user) => emit(AuthAuthenticated(user)),
  );
}
```

### Auth Screens

All screens use `BlocListener` to react to state changes:

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      context.go(AppRouter.home);
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: // Screen content
)
```

---

## Error Handling

All repository methods return `Either<Failure, T>` for explicit error handling:

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
```

Usage in Bloc:

```dart
result.fold(
  (failure) => emit(AuthError(failure.message)),
  (user) => emit(AuthAuthenticated(user)),
);
```
