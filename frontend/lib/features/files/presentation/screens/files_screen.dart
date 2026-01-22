import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/file_item.dart';
import '../bloc/files_bloc.dart';
import '../widgets/file_category_tabs.dart';
import '../widgets/file_grid.dart';

/// Files Screen
///
/// Main file manager screen with category tabs and file grid.
class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FilesBloc>()..add(const LoadFiles()),
      child: const _FilesScreenContent(),
    );
  }
}

class _FilesScreenContent extends StatelessWidget {
  const _FilesScreenContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, isDark),
            // Category Tabs
            BlocBuilder<FilesBloc, FilesState>(
              builder: (context, state) {
                if (state is FilesLoaded) {
                  return FileCategoryTabs(
                    selectedCategory: state.selectedCategory,
                    fileCounts: state.fileCounts,
                    onCategoryChanged: (category) {
                      context.read<FilesBloc>().add(ChangeCategory(category));
                    },
                  );
                }
                return const SizedBox(height: 48);
              },
            ),
            // File grid or empty state
            Expanded(
              child: BlocBuilder<FilesBloc, FilesState>(
                builder: (context, state) {
                  if (state is FilesLoading) {
                    return _buildLoadingState(isDark);
                  }
                  if (state is FilesError) {
                    return _buildErrorState(context, state.message, isDark);
                  }
                  if (state is FilesLoaded) {
                    if (state.files.isEmpty) {
                      return _buildEmptyState(state.selectedCategory, isDark);
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<FilesBloc>().add(const RefreshFiles());
                        // Wait a bit for the refresh
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: FileGrid(
                        files: state.files,
                        onFileTap: (file) => _onFileTap(context, file),
                        onFileLongPress: (file) =>
                            _onFileLongPress(context, file, isDark),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
              Icons.folder_rounded,
              size: 22,
              color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Files',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Implement search
            },
            icon: Icon(
              Icons.search_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading files',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<FilesBloc>().add(const RefreshFiles());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(FileType category, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 40,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${category.displayName.toLowerCase()} found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Files in this category will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }

  void _onFileTap(BuildContext context, FileItem file) {
    // TODO: Implement file preview
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped: ${file.name}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onFileLongPress(BuildContext context, FileItem file, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FileOptionsSheet(file: file, isDark: isDark),
    );
  }
}

class _FileOptionsSheet extends StatelessWidget {
  final FileItem file;
  final bool isDark;

  const _FileOptionsSheet({required this.file, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      file.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    file.formattedSize,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _OptionTile(
              icon: Icons.visibility_rounded,
              label: 'Preview',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement preview
              },
            ),
            _OptionTile(
              icon: Icons.share_rounded,
              label: 'Share',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            _OptionTile(
              icon: Icons.info_outline_rounded,
              label: 'Details',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement details
              },
            ),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              isDark: isDark,
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                // TODO: Confirm and delete
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.isDark,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
