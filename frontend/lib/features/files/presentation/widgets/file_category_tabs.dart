import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/file_item.dart';

/// File Category Tabs
///
/// Horizontal scrollable tabs for file categories with count badges.
class FileCategoryTabs extends StatelessWidget {
  final FileType selectedCategory;
  final Map<FileType, int> fileCounts;
  final ValueChanged<FileType> onCategoryChanged;

  const FileCategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.fileCounts,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: FileType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = FileType.values[index];
          final isSelected = category == selectedCategory;
          final count = fileCounts[category] ?? 0;

          return _CategoryChip(
            category: category,
            isSelected: isSelected,
            count: count,
            isDark: isDark,
            onTap: () => onCategoryChanged(category),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final FileType category;
  final bool isSelected;
  final int count;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.count,
    required this.isDark,
    required this.onTap,
  });

  IconData get _icon {
    switch (category) {
      case FileType.image:
        return Icons.image_rounded;
      case FileType.video:
        return Icons.video_library_rounded;
      case FileType.audio:
        return Icons.audiotrack_rounded;
      case FileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileType.text:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.darkAccent : AppColors.lightPrimary;
    final backgroundColor = isSelected
        ? (isDark ? AppColors.purple20 : activeColor.withOpacity(0.1))
        : (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = isSelected
        ? activeColor
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(
                category.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withOpacity(0.2)
                        : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
