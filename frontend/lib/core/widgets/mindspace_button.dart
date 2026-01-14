import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Mindspace Button Widget
///
/// A customizable button with multiple variants matching the design system.
/// Supports loading state, icons, and animations.
class MindspaceButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final MindspaceButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final IconData? leadingIcon;
  final Widget? leadingWidget;
  final double? width;
  final double height;

  const MindspaceButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = MindspaceButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.leadingIcon,
    this.leadingWidget,
    this.width,
    this.height = 52,
  });

  /// Primary filled button
  const MindspaceButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.leadingIcon,
    this.leadingWidget,
    this.width,
    this.height = 52,
  }) : variant = MindspaceButtonVariant.primary;

  /// Outlined button
  const MindspaceButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.leadingIcon,
    this.leadingWidget,
    this.width,
    this.height = 52,
  }) : variant = MindspaceButtonVariant.outlined;

  /// Text-only button
  const MindspaceButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = false,
    this.leadingIcon,
    this.leadingWidget,
    this.width,
    this.height = 44,
  }) : variant = MindspaceButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buttonChild = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(isDark),
              ),
            ),
          )
        else ...[
          if (leadingWidget != null) ...[
            leadingWidget!,
            const SizedBox(width: 12),
          ] else if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 20),
            const SizedBox(width: 12),
          ],
          Text(text),
        ],
      ],
    );

    Widget button;
    switch (variant) {
      case MindspaceButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(
              width ?? (isExpanded ? double.infinity : 0),
              height,
            ),
            backgroundColor: isDark
                ? AppColors.darkPrimary
                : AppColors.lightPrimary,
            foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
            disabledBackgroundColor: isDark
                ? AppColors.darkPrimary.withOpacity(0.5)
                : AppColors.lightPrimary.withOpacity(0.5),
          ),
          child: buttonChild,
        );
        break;

      case MindspaceButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(
              width ?? (isExpanded ? double.infinity : 0),
              height,
            ),
            foregroundColor: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: buttonChild,
        );
        break;

      case MindspaceButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(width ?? 0, height),
            foregroundColor: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          child: buttonChild,
        );
        break;
    }

    return button
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
          duration: 200.ms,
        );
  }

  Color _getLoadingColor(bool isDark) {
    switch (variant) {
      case MindspaceButtonVariant.primary:
        return isDark ? AppColors.darkBackground : Colors.white;
      case MindspaceButtonVariant.outlined:
      case MindspaceButtonVariant.text:
        return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    }
  }
}

/// Button variants matching the design system
enum MindspaceButtonVariant { primary, outlined, text }
