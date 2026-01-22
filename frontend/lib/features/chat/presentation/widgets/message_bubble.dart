import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/message.dart';

/// Message Bubble
///
/// Displays a single chat message with styling based on role.
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (message.isLoading) {
      return _buildLoadingBubble(isDark);
    }

    return Align(
          alignment: message.isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: EdgeInsets.only(
              left: message.isUser ? 48 : 0,
              right: message.isUser ? 0 : 48,
              bottom: 8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message.isUser
                  ? (isDark ? AppColors.darkAccent : AppColors.lightPrimary)
                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                bottomRight: Radius.circular(message.isUser ? 4 : 16),
              ),
              border: message.isAssistant
                  ? Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: message.isUser
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    message.formattedTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: message.isUser
                          ? Colors.white70
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 200.ms);
  }

  Widget _buildLoadingBubble(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 48, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LoadingDot(delay: 0.ms, isDark: isDark),
            const SizedBox(width: 4),
            _LoadingDot(delay: 150.ms, isDark: isDark),
            const SizedBox(width: 4),
            _LoadingDot(delay: 300.ms, isDark: isDark),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _LoadingDot extends StatelessWidget {
  final Duration delay;
  final bool isDark;

  const _LoadingDot({required this.delay, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            shape: BoxShape.circle,
          ),
        )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
          delay: delay,
        )
        .scaleXY(begin: 0.5, end: 1, duration: 400.ms, curve: Curves.easeInOut)
        .fadeIn(duration: 200.ms);
  }
}
