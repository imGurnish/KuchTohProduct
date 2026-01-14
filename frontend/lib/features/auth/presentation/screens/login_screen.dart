import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/auth_bloc.dart';

/// Login Screen
///
/// Premium email/password login form with responsive layout.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is AuthAuthenticated) {
          context.go(AppRouter.home);
        } else if (state is AuthNeedsVerification) {
          context.go(
            '${AppRouter.emailVerification}?email=${Uri.encodeComponent(state.email)}',
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: ResponsiveBuilder(
        builder: (context, screenType, constraints) {
          if (screenType == ScreenType.desktop) {
            return _buildDesktopLayout(context);
          }
          return _buildMobileLayout(context);
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // Left side - Decorative
          Expanded(
            flex: 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1a1a3e), const Color(0xFF2d1b4e)]
                      : [const Color(0xFFF0EDFF), const Color(0xFFE8ECFF)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 100,
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.lightPrimary,
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ).animate(delay: 200.ms).fadeIn(),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in to continue to your workspace',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ).animate(delay: 300.ms).fadeIn(),
                  ],
                ),
              ),
            ),
          ),
          // Right side - Form
          Expanded(
            flex: 50,
            child: Container(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              child: Stack(
                children: [
                  // Back button
                  Positioned(
                    top: 24,
                    left: 24,
                    child: _buildBackButton(isDark),
                  ),
                  // Form
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(48),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildForm(context, isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = context.isTablet;
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkBackground, const Color(0xFF12122a)]
                : [AppColors.lightBackground, const Color(0xFFF0F0F8)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - padding.top - padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Back button
                      _buildBackButton(isDark),
                      SizedBox(height: isTablet ? 48 : 32),
                      // Form
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 420 : double.infinity,
                          ),
                          child: _buildForm(context, isDark),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(bool isDark) {
    return IconButton(
      onPressed: () => context.pop(),
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        size: 20,
      ),
      style: IconButton.styleFrom(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        padding: const EdgeInsets.all(12),
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildForm(BuildContext context, bool isDark) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Sign In',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Enter your credentials to continue',
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 40),

          // Email field
          _buildLabel('Email', isDark),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            isDark: isDark,
            hint: 'you@example.com',
            icon: Icons.email_outlined,
            error: _emailError,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() => _emailError = null),
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 20),

          // Password field
          _buildLabel('Password', isDark),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            isDark: isDark,
            hint: '••••••••',
            icon: Icons.lock_outline,
            error: _passwordError,
            obscureText: _obscurePassword,
            onChanged: (_) => setState(() => _passwordError = null),
            onSubmitted: (_) => _handleLogin(),
            suffix: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 12),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(AppRouter.passwordRecovery),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkAccent
                      : const Color(0xFF6B4EFF),
                ),
              ),
            ),
          ).animate(delay: 400.ms).fadeIn(),

          const SizedBox(height: 32),

          // Sign in button
          _buildPrimaryButton(
            text: 'Sign In',
            isDark: isDark,
            onPressed: _handleLogin,
            isLoading: _isLoading,
          ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Sign up link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              GestureDetector(
                onTap: () => context.pushReplacement(AppRouter.signup),
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkAccent
                        : const Color(0xFF6B4EFF),
                  ),
                ),
              ),
            ],
          ).animate(delay: 600.ms).fadeIn(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isDark,
    required String hint,
    required IconData icon,
    String? error,
    bool obscureText = false,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: error != null
            ? [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              suffixIcon: suffix,
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: error != null
                      ? AppColors.error
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: error != null
                      ? AppColors.error
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: error != null
                      ? AppColors.error
                      : (isDark
                            ? AppColors.darkAccent
                            : const Color(0xFF6B4EFF)),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                error,
                style: const TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required bool isDark,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? AppColors.darkPrimary
              : AppColors.lightPrimary,
          foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? AppColors.darkBackground : Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _handleLogin() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool hasError = false;

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      hasError = true;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email');
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      hasError = true;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      hasError = true;
    }

    if (hasError) return;

    // Dispatch sign in event to AuthBloc
    context.read<AuthBloc>().add(
      AuthSignInRequested(email: email, password: password),
    );
  }
}
