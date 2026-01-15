import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/password_recovery_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/whisper_test/presentation/pages/whisper_test_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// App Router Configuration
///
/// Uses go_router for declarative routing with auth state-based redirects.
class AppRouter {
  AppRouter._();

  /// Route paths
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String passwordRecovery = '/password-recovery';
  static const String emailVerification = '/email-verification';
  static const String home = '/home';
  static const String whisperTest = '/whisper-test';

  /// Public routes that don't require authentication
  static const List<String> publicRoutes = [
    welcome,
    login,
    signup,
    passwordRecovery,
    emailVerification,
  ];

  /// Create router with auth state
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: welcome,
      debugLogDiagnostics: true,
      refreshListenable: _AuthStateNotifier(authBloc),
      routes: [
        // Welcome/Landing Screen
        GoRoute(
          path: welcome,
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),

        // Login Screen
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Signup Screen
        GoRoute(
          path: signup,
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),

        // Password Recovery Screen
        GoRoute(
          path: passwordRecovery,
          name: 'passwordRecovery',
          builder: (context, state) => const PasswordRecoveryScreen(),
        ),

        // Email Verification Screen
        GoRoute(
          path: emailVerification,
          name: 'emailVerification',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return EmailVerificationScreen(email: email);
          },
        ),

        // Home Screen (authenticated)
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        // Whisper Test Screen
        GoRoute(
          path: whisperTest,
          name: 'whisperTest',
          builder: (context, state) => const WhisperTestPage(),
        ),
      ],

      // Redirect logic for auth state
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isPublicRoute = publicRoutes.contains(state.matchedLocation);

        // If authenticated and on public route, go to home
        if (isAuthenticated && isPublicRoute) {
          return home;
        }

        // If not authenticated and on protected route, go to welcome
        if (!isAuthenticated && !isPublicRoute) {
          return welcome;
        }

        return null;
      },
    );
  }

  /// Legacy router for backward compatibility (without auth)
  static final GoRouter router = GoRouter(
    initialLocation: welcome,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: passwordRecovery,
        name: 'passwordRecovery',
        builder: (context, state) => const PasswordRecoveryScreen(),
      ),
      GoRoute(
        path: emailVerification,
        name: 'emailVerification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: whisperTest,
        name: 'whisperTest',
        builder: (context, state) => const WhisperTestPage(),
      ),
    ],
  );
}

/// Notifier that listens to AuthBloc state changes
class _AuthStateNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;

  _AuthStateNotifier(this._authBloc) {
    _authBloc.stream.listen((_) {
      notifyListeners();
    });
  }
}
