import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/file_item.dart';

/// File Detail Sheet
///
/// Shows full file metadata in a bottom sheet.
class FileDetailSheet extends StatelessWidget {
  final FileItem file;
  final VoidCallback? onDelete;

  const FileDetailSheet({super.key, required this.file, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // File name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildIcon(isDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          file.type.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Metadata
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Size', file.formattedSize, isDark),
                  const Divider(height: 20),
                  _buildInfoRow(
                    'Modified',
                    dateFormat.format(file.modifiedAt),
                    isDark,
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    'Created',
                    dateFormat.format(file.createdAt),
                    isDark,
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    'Extension',
                    file.extension.toUpperCase(),
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Path
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    file.path,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete!();
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    Color color;
    IconData icon;

    switch (file.type) {
      case FileType.image:
        color = isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);
        icon = Icons.image_rounded;
      case FileType.video:
        color = isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
        icon = Icons.play_circle_rounded;
      case FileType.audio:
        color = isDark ? const Color(0xFFF472B6) : const Color(0xFFEC4899);
        icon = Icons.music_note_rounded;
      case FileType.pdf:
        color = isDark ? const Color(0xFFFB7185) : const Color(0xFFEF4444);
        icon = Icons.picture_as_pdf_rounded;
      case FileType.text:
        color = isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
        icon = Icons.description_rounded;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
