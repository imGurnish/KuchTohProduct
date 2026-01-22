part of 'files_bloc.dart';

/// Permission status
enum PermissionStatus { unknown, granted, denied, permanentlyDenied }

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

/// Files loaded successfully
class FilesLoaded extends FilesState {
  final List<FileItem> files;
  final List<FileItem> allFiles; // Original unfiltered list
  final FileType selectedCategory;
  final Map<FileType, int> fileCounts;
  final String searchQuery;
  final bool isSearching;

  const FilesLoaded({
    required this.files,
    required this.allFiles,
    required this.selectedCategory,
    required this.fileCounts,
    this.searchQuery = '',
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [
    files,
    allFiles,
    selectedCategory,
    fileCounts,
    searchQuery,
    isSearching,
  ];

  FilesLoaded copyWith({
    List<FileItem>? files,
    List<FileItem>? allFiles,
    FileType? selectedCategory,
    Map<FileType, int>? fileCounts,
    String? searchQuery,
    bool? isSearching,
  }) {
    return FilesLoaded(
      files: files ?? this.files,
      allFiles: allFiles ?? this.allFiles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      fileCounts: fileCounts ?? this.fileCounts,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
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
