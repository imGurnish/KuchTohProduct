import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated recording button with visual feedback
class RecordingButton extends StatelessWidget {
  final bool isRecording;
  final bool isProcessing;
  final VoidCallback onPressed;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: isProcessing ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isRecording ? 100 : 80,
        height: isRecording ? 100 : 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isProcessing
              ? colorScheme.surfaceContainerHighest
              : isRecording
              ? colorScheme.error
              : colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: (isRecording ? colorScheme.error : colorScheme.primary)
                  .withValues(alpha: 0.4),
              blurRadius: isRecording ? 24 : 12,
              spreadRadius: isRecording ? 4 : 0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing ring animation when recording
            if (isRecording)
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.5),
                        width: 3,
                      ),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.5, 1.5),
                    duration: 1000.ms,
                  )
                  .fadeOut(duration: 1000.ms),
            // Icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isProcessing
                  ? SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: colorScheme.onSurface,
                      ),
                    )
                  : Icon(
                      isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      key: ValueKey(isRecording),
                      size: 40,
                      color: colorScheme.onPrimary,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
