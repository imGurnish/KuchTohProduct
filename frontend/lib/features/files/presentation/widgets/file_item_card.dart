import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/file_item.dart';

/// File Item Card
///
/// Displays a single file with thumbnail/icon, name, and size.
class FileItemCard extends StatelessWidget {
  final FileItem file;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FileItemCard({
    super.key,
    required this.file,
    this.onTap,
    this.onLongPress,
  });

  IconData get _icon {
    switch (file.type) {
      case FileType.image:
        return Icons.image_rounded;
      case FileType.video:
        return Icons.play_circle_rounded;
      case FileType.audio:
        return Icons.audiotrack_rounded;
      case FileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileType.text:
        return Icons.description_rounded;
    }
  }

  Color _getIconColor(bool isDark) {
    switch (file.type) {
      case FileType.image:
        return isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);
      case FileType.video:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
      case FileType.audio:
        return isDark ? const Color(0xFFF472B6) : const Color(0xFFEC4899);
      case FileType.pdf:
        return isDark ? const Color(0xFFFB7185) : const Color(0xFFEF4444);
      case FileType.text:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
    }
  }

  Color _getIconBackgroundColor(bool isDark) {
    final color = _getIconColor(isDark);
    return color.withOpacity(isDark ? 0.2 : 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail/Icon area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(_icon, size: 40, color: _getIconColor(isDark)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // File name
              Text(
                file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // File size
              Text(
                file.formattedSize,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
