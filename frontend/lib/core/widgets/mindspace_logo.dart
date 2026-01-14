import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Mindspace Logo Widget
///
/// Displays the app logo icon and name with optional tagline.
/// Matches the premium design from the mockup.
class MindspaceLogo extends StatelessWidget {
  final bool showTagline;
  final double iconSize;
  final double titleSize;
  final MainAxisAlignment alignment;

  const MindspaceLogo({
    super.key,
    this.showTagline = true,
    this.iconSize = 64,
    this.titleSize = 28,
    this.alignment = MainAxisAlignment.center,
  });

  /// Compact version for app bars
  const MindspaceLogo.compact({
    super.key,
    this.showTagline = false,
    this.iconSize = 32,
    this.titleSize = 20,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon Container
        Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(iconSize * 0.25),
              ),
              child: Center(
                child: Icon(
                  Icons.psychology_outlined,
                  size: iconSize * 0.5,
                  color: isDark ? AppColors.darkBackground : Colors.white,
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: 16),

        // App Name
        Text(
          'Mindspace',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            letterSpacing: -0.5,
          ),
        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

        // Tagline
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Capture everything, remember all.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
        ],
      ],
    );
  }
}

/// Animated brain icon for the logo
class MindspaceAnimatedIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const MindspaceAnimatedIcon({super.key, this.size = 32, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        color ?? (isDark ? AppColors.darkBackground : Colors.white);

    return Icon(Icons.psychology_outlined, size: size, color: iconColor)
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 2000.ms,
          delay: 1000.ms,
          color: iconColor.withOpacity(0.3),
        );
  }
}
