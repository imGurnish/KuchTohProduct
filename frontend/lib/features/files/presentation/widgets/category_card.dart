import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/file_item.dart';

/// Category Card Widget
///
/// Displays a category with icon, name, and file count in a Google Files style.
class CategoryCard extends StatelessWidget {
  final FileType type;
  final int count;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.type,
    required this.count,
    required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case FileType.image:
        return Icons.image_rounded;
      case FileType.video:
        return Icons.play_circle_rounded;
      case FileType.audio:
        return Icons.music_note_rounded;
      case FileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileType.text:
        return Icons.description_rounded;
    }
  }

  Color _getColor(bool isDark) {
    switch (type) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor(isDark);

    return Material(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icon, color: color, size: 26),
                  ),
                  const Spacer(),
                  // Name
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Count
                  Text(
                    '$count ${count == 1 ? 'file' : 'files'}',
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
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 200.ms,
        );
  }
}

/// Categories Grid
///
/// Responsive grid of category cards.
class CategoriesGrid extends StatelessWidget {
  final Map<FileType, int> fileCounts;
  final Function(FileType) onCategoryTap;

  const CategoriesGrid({
    super.key,
    required this.fileCounts,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Responsive columns: mobile=2, tablet=3, desktop=4+
    int crossAxisCount = 2;
    if (width > 600) crossAxisCount = 3;
    if (width > 900) crossAxisCount = 4;
    if (width > 1200) crossAxisCount = 5;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: FileType.values.length,
      itemBuilder: (context, index) {
        final type = FileType.values[index];
        return CategoryCard(
          type: type,
          count: fileCounts[type] ?? 0,
          onTap: () => onCategoryTap(type),
        );
      },
    );
  }
}
