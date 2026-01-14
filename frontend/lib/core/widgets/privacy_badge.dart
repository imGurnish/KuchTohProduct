import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Privacy Badge Widget
///
/// Displays privacy assurance badge as shown in the design.
/// "Privacy-Focused Architecture" with shield icon.
class PrivacyBadge extends StatelessWidget {
  final String text;
  final IconData icon;

  const PrivacyBadge({
    super.key,
    this.text = 'Privacy-Focused Architecture',
    this.icon = Icons.verified_user_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.purple20 : AppColors.lightInputBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.darkAccent.withOpacity(0.3)
                  : AppColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark
                    ? AppColors.darkAccent
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkAccent
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        )
        .animate(delay: 600.ms)
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

/// Privacy Notice Widget
///
/// Displays the full privacy notice text below the badge.
class PrivacyNotice extends StatelessWidget {
  const PrivacyNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Your data is encrypted locally and never sold. You own your Mindspace.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppColors.darkTextMuted
              : AppColors.lightTextSecondary,
          height: 1.5,
        ),
      ),
    ).animate(delay: 800.ms).fadeIn(duration: 400.ms);
  }
}
