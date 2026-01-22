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
/// Main file manager screen with search, category tabs, and file grid.
class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FilesBloc>()..add(const CheckPermission()),
      child: _FilesScreenContent(
        isSearching: _isSearching,
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        onSearchToggle: () {
          setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) {
              _searchController.clear();
            } else {
              _searchFocusNode.requestFocus();
            }
          });
        },
        onSearchClear: () {
          _searchController.clear();
          setState(() => _isSearching = false);
        },
      ),
    );
  }
}

class _FilesScreenContent extends StatelessWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchToggle;
  final VoidCallback onSearchClear;

  const _FilesScreenContent({
    required this.isSearching,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchToggle,
    required this.onSearchClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: BlocBuilder<FilesBloc, FilesState>(
          builder: (context, state) {
            if (state is FilesCheckingPermission) {
              return _buildLoadingState(isDark);
            }
            if (state is FilesPermissionRequired) {
              return _buildPermissionRequired(context, state, isDark);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with search
                _buildHeader(context, isDark),
                // Category Tabs
                BlocBuilder<FilesBloc, FilesState>(
                  builder: (context, state) {
                    if (state is FilesLoaded) {
                      return FileCategoryTabs(
                        selectedCategory: state.selectedCategory,
                        fileCounts: state.fileCounts,
                        onCategoryChanged: (category) {
                          searchController.clear();
                          context.read<FilesBloc>().add(
                            ChangeCategory(category),
                          );
                        },
                      );
                    }
                    return const SizedBox(height: 48);
                  },
                ),
                // Search results info
                BlocBuilder<FilesBloc, FilesState>(
                  builder: (context, state) {
                    if (state is FilesLoaded && state.isSearching) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Text(
                          '${state.files.length} result${state.files.length == 1 ? '' : 's'} for "${state.searchQuery}"',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
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
                          if (state.isSearching) {
                            return _buildNoSearchResults(
                              state.searchQuery,
                              isDark,
                            );
                          }
                          return _buildEmptyState(
                            state.selectedCategory,
                            isDark,
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<FilesBloc>().add(const RefreshFiles());
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          if (!isSearching) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.purple20
                    : AppColors.lightPrimary.withValues(alpha: 0.1),
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
          ],
          if (isSearching)
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: (query) {
                    context.read<FilesBloc>().add(SearchFiles(query));
                  },
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search files...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            onPressed: () {
                              searchController.clear();
                              context.read<FilesBloc>().add(
                                const ClearSearch(),
                              );
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          if (isSearching) const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (isSearching) {
                context.read<FilesBloc>().add(const ClearSearch());
              }
              onSearchToggle();
            },
            icon: Icon(
              isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            tooltip: isSearching ? 'Close search' : 'Search files',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildNoSearchResults(String query, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$query"',
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
              'Try a different search term',
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

  Widget _buildPermissionRequired(
    BuildContext context,
    FilesPermissionRequired state,
    bool isDark,
  ) {
    final isPermanentlyDenied =
        state.status == PermissionStatus.permanentlyDenied;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.purple20
                    : AppColors.lightPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_off_rounded,
                size: 50,
                color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Storage Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPermanentlyDenied
                  ? 'Permission was denied. Please enable storage access in Settings.'
                  : 'Mindspace needs access to your files to display and manage them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (isPermanentlyDenied) {
                    context.read<FilesBloc>().add(const OpenSettings());
                  } else {
                    context.read<FilesBloc>().add(const RequestPermission());
                  }
                },
                icon: Icon(
                  isPermanentlyDenied
                      ? Icons.settings_rounded
                      : Icons.lock_open_rounded,
                ),
                label: Text(
                  isPermanentlyDenied ? 'Open Settings' : 'Grant Permission',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkAccent
                      : AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${file.name}'),
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
      builder: (sheetContext) => _FileOptionsSheet(
        file: file,
        isDark: isDark,
        onDelete: () {
          Navigator.pop(sheetContext);
          _confirmDelete(context, file, isDark);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, FileItem file, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        title: Text(
          'Delete File',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this file?',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              file.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FilesBloc>().add(DeleteFile(file.id));
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileOptionsSheet extends StatelessWidget {
  final FileItem file;
  final bool isDark;
  final VoidCallback onDelete;

  const _FileOptionsSheet({
    required this.file,
    required this.isDark,
    required this.onDelete,
  });

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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                file.path,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            _OptionTile(
              icon: Icons.info_outline_rounded,
              label: 'Details',
              isDark: isDark,
              onTap: () => Navigator.pop(context),
            ),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              isDark: isDark,
              isDestructive: true,
              onTap: onDelete,
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
