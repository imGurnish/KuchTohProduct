import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Auth Card Widget
///
/// Container card for authentication forms with consistent styling.
class AuthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;

  const AuthCard({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.black10,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withOpacity(0.5))
            : null,
      ),
      child: child,
    );
  }
}
