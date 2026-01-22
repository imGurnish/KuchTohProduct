part of 'files_bloc.dart';

/// Permission status
enum PermissionStatus { unknown, granted, denied, permanentlyDenied }

/// Current view mode
enum FilesViewMode { home, category, search }

/// Files BLoC States
abstract class FilesState extends Equatable {
  const FilesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FilesInitial extends FilesState {
  const FilesInitial();
}

/// Checking permission
class FilesCheckingPermission extends FilesState {
  const FilesCheckingPermission();
}

/// Permission required
class FilesPermissionRequired extends FilesState {
  final PermissionStatus status;

  const FilesPermissionRequired({this.status = PermissionStatus.denied});

  @override
  List<Object?> get props => [status];
}

/// Loading files
class FilesLoading extends FilesState {
  const FilesLoading();
}

/// Files ready - home, category, or search view
class FilesReady extends FilesState {
  final FilesViewMode viewMode;
  final Map<FileType, int> fileCounts;
  final FileType? selectedCategory;
  final List<FileItem> files;
  final String searchQuery;

  const FilesReady({
    required this.viewMode,
    required this.fileCounts,
    this.selectedCategory,
    this.files = const [],
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    viewMode,
    fileCounts,
    selectedCategory,
    files,
    searchQuery,
  ];

  FilesReady copyWith({
    FilesViewMode? viewMode,
    Map<FileType, int>? fileCounts,
    FileType? selectedCategory,
    List<FileItem>? files,
    String? searchQuery,
  }) {
    return FilesReady(
      viewMode: viewMode ?? this.viewMode,
      fileCounts: fileCounts ?? this.fileCounts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      files: files ?? this.files,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Clear selected category (for use in copyWith)
  FilesReady clearCategory() {
    return FilesReady(
      viewMode: viewMode,
      fileCounts: fileCounts,
      selectedCategory: null,
      files: files,
      searchQuery: searchQuery,
    );
  }
}

/// Error loading files
class FilesError extends FilesState {
  final String message;

  const FilesError(this.message);

  @override
  List<Object?> get props => [message];
}
