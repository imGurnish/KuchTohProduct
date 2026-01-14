import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Social Authentication Button Widget
///
/// Styled buttons for Google and Email sign-in options.
class SocialAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget icon;
  final SocialAuthButtonVariant variant;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.variant = SocialAuthButtonVariant.filled,
    this.isLoading = false,
  });

  /// Google sign-in button
  factory SocialAuthButton.google({
    Key? key,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDark = false,
  }) {
    return SocialAuthButton(
      key: key,
      text: 'Continue with Google',
      icon: _GoogleLogo(isDark: isDark),
      onPressed: onPressed,
      variant: isDark
          ? SocialAuthButtonVariant.filled
          : SocialAuthButtonVariant.outlined,
      isLoading: isLoading,
    );
  }

  /// Email sign-in button
  factory SocialAuthButton.email({
    Key? key,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDark = false,
  }) {
    return SocialAuthButton(
      key: key,
      text: 'Continue with Email',
      icon: Icon(
        Icons.email_outlined,
        size: 20,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      onPressed: onPressed,
      variant: SocialAuthButtonVariant.outlined,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final buttonStyle = variant == SocialAuthButtonVariant.filled
        ? ElevatedButton.styleFrom(
            backgroundColor: isDark
                ? AppColors.darkPrimary
                : AppColors.lightSurface,
            foregroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.lightTextPrimary,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.darkBackground : AppColors.lightTextPrimary,
              ),
            ),
          )
        else ...[
          icon,
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: variant == SocialAuthButtonVariant.filled
                  ? (isDark
                        ? AppColors.darkBackground
                        : AppColors.lightTextPrimary)
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
            ),
          ),
        ],
      ],
    );

    Widget button = variant == SocialAuthButtonVariant.filled
        ? ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonContent,
          )
        : OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonContent,
          );

    return button
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}

/// Social auth button variants
enum SocialAuthButtonVariant { filled, outlined }

/// Google logo widget
class _GoogleLogo extends StatelessWidget {
  final bool isDark;

  const _GoogleLogo({this.isDark = false});

  @override
  Widget build(BuildContext context) {
    // Using a simple "G" text as placeholder,
    // In production, use flutter_svg with Google logo SVG
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFF4285F4), // Blue
                  Color(0xFFDB4437), // Red
                  Color(0xFFF4B400), // Yellow
                  Color(0xFF0F9D58), // Green
                ],
                stops: [0.25, 0.5, 0.75, 1.0],
              ).createShader(const Rect.fromLTWH(0, 0, 20, 20)),
          ),
        ),
      ),
    );
  }
}
