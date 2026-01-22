part of 'files_bloc.dart';

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

/// Loading files
class FilesLoading extends FilesState {
  const FilesLoading();
}

/// Files loaded successfully
class FilesLoaded extends FilesState {
  final List<FileItem> files;
  final FileType selectedCategory;
  final Map<FileType, int> fileCounts;

  const FilesLoaded({
    required this.files,
    required this.selectedCategory,
    required this.fileCounts,
  });

  @override
  List<Object?> get props => [files, selectedCategory, fileCounts];

  FilesLoaded copyWith({
    List<FileItem>? files,
    FileType? selectedCategory,
    Map<FileType, int>? fileCounts,
  }) {
    return FilesLoaded(
      files: files ?? this.files,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      fileCounts: fileCounts ?? this.fileCounts,
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
