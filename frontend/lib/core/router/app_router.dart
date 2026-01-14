import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/password_recovery_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';

/// App Router Configuration
///
/// Uses go_router for declarative routing with deep linking support.
class AppRouter {
  AppRouter._();

  /// Route paths
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String passwordRecovery = '/password-recovery';
  static const String emailVerification = '/email-verification';
  static const String home = '/home';

  /// Router instance
  static final GoRouter router = GoRouter(
    initialLocation: welcome,
    debugLogDiagnostics: true,
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

      // TODO: Add home and other authenticated routes
    ],

    // Redirect logic for auth state
    // redirect: (context, state) {
    //   // TODO: Implement auth state redirect
    //   return null;
    // },
  );
}
