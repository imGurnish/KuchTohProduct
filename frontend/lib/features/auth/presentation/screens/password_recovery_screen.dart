import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/responsive.dart';

/// Password Recovery Screen
///
/// Premium password reset flow with responsive layout.
class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType, constraints) {
        if (screenType == ScreenType.desktop) {
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
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
                      _emailSent
                          ? Icons.mark_email_read_outlined
                          : Icons.lock_reset_outlined,
                      size: 100,
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.lightPrimary,
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 24),
                    Text(
                      _emailSent ? 'Check your inbox' : 'Reset Password',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ).animate(delay: 200.ms).fadeIn(),
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
                        child: _buildContent(context, isDark),
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
                      _buildBackButton(isDark),
                      SizedBox(height: isTablet ? 48 : 32),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 420 : double.infinity,
                          ),
                          child: _buildContent(context, isDark),
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

  Widget _buildContent(BuildContext context, bool isDark) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: _emailSent ? _buildSuccessState(isDark) : _buildForm(isDark),
    );
  }

  Widget _buildForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: isDark ? AppColors.purple20 : const Color(0xFFF0EDFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.lock_reset_outlined,
            size: 36,
            color: isDark ? AppColors.darkAccent : const Color(0xFF6B4EFF),
          ),
        ).animate().fadeIn().scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
        ),

        const SizedBox(height: 24),

        Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ).animate(delay: 100.ms).fadeIn(),

        const SizedBox(height: 8),

        Text(
          "Enter your email and we'll send you a link to reset your password.",
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ).animate(delay: 150.ms).fadeIn(),

        const SizedBox(height: 32),

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
          onSubmitted: (_) => _handleReset(),
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),

        const SizedBox(height: 32),

        _buildPrimaryButton(
          text: 'Send Reset Link',
          isDark: isDark,
          onPressed: _handleReset,
          isLoading: _isLoading,
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSuccessState(bool isDark) {
    return Column(
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 40,
            color: AppColors.success,
          ),
        ).animate().fadeIn().scale(),

        const SizedBox(height: 32),

        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ).animate(delay: 150.ms).fadeIn(),

        const SizedBox(height: 12),

        Text(
          'We sent a password reset link to',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ).animate(delay: 200.ms).fadeIn(),

        const SizedBox(height: 4),

        Text(
          _emailController.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ).animate(delay: 250.ms).fadeIn(),

        const SizedBox(height: 32),

        // Try again button
        TextButton(
          onPressed: () => setState(() => _emailSent = false),
          child: Text(
            "Didn't receive the email? Try again",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkAccent : const Color(0xFF6B4EFF),
            ),
          ),
        ).animate(delay: 350.ms).fadeIn(),

        const SizedBox(height: 16),

        // Back to login
        _buildOutlinedButton(
          text: 'Back to Sign In',
          isDark: isDark,
          onPressed: () => context.pop(),
        ).animate(delay: 400.ms).fadeIn(),
      ],
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
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
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
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
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
                    : (isDark ? AppColors.darkAccent : const Color(0xFF6B4EFF)),
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

  Widget _buildOutlinedButton({
    required String text,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _handleReset() {
    setState(() => _emailError = null);

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    });
  }
}
