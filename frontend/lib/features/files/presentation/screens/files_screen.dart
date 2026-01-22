import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/file_item.dart';
import '../bloc/files_bloc.dart';
import '../widgets/category_card.dart';
import '../widgets/file_card.dart';
import '../widgets/file_detail_sheet.dart';

/// Files Screen - Google Files Style
///
/// Home view with categories, category view with files, global search.
class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

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
      child: Builder(builder: (context) => _buildScaffold(context)),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: BlocBuilder<FilesBloc, FilesState>(
          builder: (context, state) {
            if (state is FilesCheckingPermission || state is FilesLoading) {
              return _buildLoadingState(isDark);
            }
            if (state is FilesPermissionRequired) {
              return _buildPermissionRequired(context, state, isDark);
            }
            if (state is FilesError) {
              return _buildErrorState(context, state.message, isDark);
            }
            if (state is FilesReady) {
              return Column(
                children: [
                  _buildHeader(context, state, isDark),
                  Expanded(child: _buildContent(context, state, isDark)),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FilesReady state, bool isDark) {
    final showBack =
        state.viewMode == FilesViewMode.category ||
        state.viewMode == FilesViewMode.search;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _isSearchExpanded = false);
                context.read<FilesBloc>().add(const GoBackToHome());
              },
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            )
          else
            const SizedBox(width: 8),
          if (!_isSearchExpanded) ...[
            Text(
              _getTitle(state),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const Spacer(),
          ],
          if (_isSearchExpanded)
            Expanded(child: _buildSearchField(context, isDark))
          else ...[
            IconButton(
              onPressed: () {
                setState(() => _isSearchExpanded = true);
                _searchFocusNode.requestFocus();
              },
              icon: Icon(
                Icons.search_rounded,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            if (state.viewMode != FilesViewMode.home)
              IconButton(
                onPressed: () =>
                    context.read<FilesBloc>().add(const RefreshFiles()),
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
          ],
          if (_isSearchExpanded)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _isSearchExpanded = false);
                context.read<FilesBloc>().add(const ClearSearch());
              },
              icon: Icon(
                Icons.close_rounded,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
        ],
      ),
    );
  }

  String _getTitle(FilesReady state) {
    if (state.viewMode == FilesViewMode.search) return 'Search';
    if (state.viewMode == FilesViewMode.category &&
        state.selectedCategory != null) {
      return state.selectedCategory!.displayName;
    }
    return 'Files';
  }

  Widget _buildSearchField(BuildContext context, bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (query) {
          context.read<FilesBloc>().add(SearchAllFiles(query));
        },
        style: TextStyle(
          fontSize: 15,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search all files...',
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FilesReady state, bool isDark) {
    switch (state.viewMode) {
      case FilesViewMode.home:
        return _buildHomeView(context, state, isDark);
      case FilesViewMode.category:
      case FilesViewMode.search:
        return _buildFilesGrid(context, state, isDark);
    }
  }

  Widget _buildHomeView(BuildContext context, FilesReady state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          CategoriesGrid(
            fileCounts: state.fileCounts,
            onCategoryTap: (type) {
              context.read<FilesBloc>().add(OpenCategory(type));
            },
          ),
          const SizedBox(height: 24),
          // Quick access section (placeholder for recent files)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Storage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          _buildStorageInfo(state, isDark),
        ],
      ),
    );
  }

  Widget _buildStorageInfo(FilesReady state, bool isDark) {
    final totalFiles = state.fileCounts.values.fold(0, (a, b) => a + b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.purple20
                  : AppColors.lightPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.folder_rounded,
              color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Files',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalFiles files indexed',
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
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildFilesGrid(BuildContext context, FilesReady state, bool isDark) {
    if (state.files.isEmpty) {
      return _buildEmptyState(state, isDark);
    }

    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width > 600) crossAxisCount = 3;
    if (width > 900) crossAxisCount = 4;
    if (width > 1200) crossAxisCount = 6;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FilesBloc>().add(const RefreshFiles());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: state.files.length,
        itemBuilder: (context, index) {
          final file = state.files[index];
          return FileCard(
            file: file,
            onTap: () => _showFileDetail(context, file),
            onLongPress: () => _showFileDetail(context, file),
          );
        },
      ),
    );
  }

  void _showFileDetail(BuildContext context, FileItem file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FileDetailSheet(
        file: file,
        onDelete: () {
          context.read<FilesBloc>().add(DeleteFile(file.id));
        },
      ),
    );
  }

  Widget _buildEmptyState(FilesReady state, bool isDark) {
    final isSearch = state.viewMode == FilesViewMode.search;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearch ? Icons.search_off_rounded : Icons.folder_open_rounded,
            size: 64,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            isSearch
                ? 'No results for "${state.searchQuery}"'
                : 'No files found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch ? 'Try a different search term' : 'Files will appear here',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
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
              'Error',
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
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.read<FilesBloc>().add(const RefreshFiles()),
              child: const Text('Retry'),
            ),
          ],
        ),
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.purple20
                    : AppColors.lightPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_off_rounded,
                size: 40,
                color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Storage Permission Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPermanentlyDenied
                  ? 'Enable storage access in Settings'
                  : 'Allow access to view your files',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
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
                isPermanentlyDenied ? 'Open Settings' : 'Grant Access',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkAccent
                    : AppColors.lightPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
