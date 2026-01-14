import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/responsive.dart';

/// Email Verification Screen
///
/// Premium email verification prompt with responsive layout.
class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _resendSuccess = false;
  int _resendCooldown = 0;

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
                      Icons.mark_email_unread_outlined,
                      size: 100,
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.lightPrimary,
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 24),
                    Text(
                      'Verify Your Email',
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
                      'One more step to get started',
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
          // Right side - Content
          Expanded(
            flex: 50,
            child: Container(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              child: Stack(
                children: [
                  // Close button
                  Positioned(
                    top: 24,
                    right: 24,
                    child: IconButton(
                      onPressed: () => context.go(AppRouter.welcome),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        padding: const EdgeInsets.all(12),
                      ),
                    ).animate().fadeIn(),
                  ),
                  // Content
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
                    children: [
                      const SizedBox(height: 16),
                      // Close button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => context.go(AppRouter.welcome),
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                              padding: const EdgeInsets.all(12),
                            ),
                          ).animate().fadeIn(),
                        ],
                      ),
                      const Spacer(),
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

  Widget _buildContent(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Email icon
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: isDark ? AppColors.purple20 : const Color(0xFFF0EDFF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.mark_email_unread_outlined,
            size: 44,
            color: isDark ? AppColors.darkAccent : const Color(0xFF6B4EFF),
          ),
        ).animate().fadeIn().scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
        ),

        const SizedBox(height: 32),

        Text(
          'Verify your email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ).animate(delay: 100.ms).fadeIn(),

        const SizedBox(height: 12),

        Text(
          "We've sent a verification link to",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ).animate(delay: 150.ms).fadeIn(),

        const SizedBox(height: 4),

        Text(
          widget.email,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ).animate(delay: 200.ms).fadeIn(),

        const SizedBox(height: 32),

        // Instructions
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              _buildInstruction(
                isDark,
                1,
                'Check your inbox (and spam folder)',
              ),
              const SizedBox(height: 16),
              _buildInstruction(
                isDark,
                2,
                'Click the verification link in the email',
              ),
              const SizedBox(height: 16),
              _buildInstruction(isDark, 3, 'Return here and sign in'),
            ],
          ),
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

        const SizedBox(height: 32),

        // Resend button
        if (_resendSuccess)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Email sent!',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn()
        else
          TextButton(
            onPressed: _resendCooldown > 0 || _isResending
                ? null
                : _handleResend,
            child: _isResending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark
                          ? AppColors.darkAccent
                          : const Color(0xFF6B4EFF),
                    ),
                  )
                : Text(
                    _resendCooldown > 0
                        ? 'Resend email in ${_resendCooldown}s'
                        : "Didn't receive email? Resend",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _resendCooldown > 0
                          ? (isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary)
                          : (isDark
                                ? AppColors.darkAccent
                                : const Color(0xFF6B4EFF)),
                    ),
                  ),
          ),

        const SizedBox(height: 32),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go(AppRouter.login),
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
            child: const Text(
              'Continue to Sign In',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ).animate(delay: 450.ms).fadeIn(),

        const SizedBox(height: 16),

        // Change email
        TextButton(
          onPressed: () => context.go(AppRouter.signup),
          child: Text(
            'Use a different email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ).animate(delay: 500.ms).fadeIn(),
      ],
    );
  }

  Widget _buildInstruction(bool isDark, int number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkAccent.withOpacity(0.2)
                : const Color(0xFFF0EDFF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkAccent : const Color(0xFF6B4EFF),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _handleResend() async {
    setState(() => _isResending = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isResending = false;
        _resendSuccess = true;
        _resendCooldown = 60;
      });

      _startCooldown();

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _resendSuccess = false);
      });
    }
  }

  void _startCooldown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      return _resendCooldown > 0;
    });
  }
}
