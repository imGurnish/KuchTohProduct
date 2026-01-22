import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

/// Backups Screen (Placeholder)
///
/// Coming soon screen for Google Drive backup feature.
class BackupsScreen extends StatelessWidget {
  const BackupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),
            // Coming Soon Content
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.purple20
                              : AppColors.lightPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_rounded,
                          size: 50,
                          color: isDark
                              ? AppColors.darkAccent
                              : AppColors.lightPrimary,
                        ),
                      ).animate().fadeIn().scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutBack,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Backups',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ).animate(delay: 100.ms).fadeIn(),
                      const SizedBox(height: 12),
                      Text(
                        'Google Drive backup coming soon',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ).animate(delay: 200.ms).fadeIn(),
                      const SizedBox(height: 32),
                      Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Column(
                              children: [
                                _FeatureItem(
                                  icon: Icons.cloud_upload_rounded,
                                  text: 'Backup to your Google Drive',
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 12),
                                _FeatureItem(
                                  icon: Icons.sync_rounded,
                                  text: 'Automatic sync across devices',
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 12),
                                _FeatureItem(
                                  icon: Icons.lock_rounded,
                                  text: 'Your files, your control',
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          )
                          .animate(delay: 300.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.purple20
                  : AppColors.lightPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.cloud_rounded,
              size: 22,
              color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Backups',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
        ),
        const SizedBox(width: 12),
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
}
