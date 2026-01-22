part of 'files_bloc.dart';

/// Files BLoC Events
abstract class FilesEvent extends Equatable {
  const FilesEvent();

  @override
  List<Object?> get props => [];
}

/// Check and request permission if needed
class CheckPermission extends FilesEvent {
  const CheckPermission();
}

/// Request storage permission
class RequestPermission extends FilesEvent {
  const RequestPermission();
}

/// Open app settings
class OpenSettings extends FilesEvent {
  const OpenSettings();
}

/// Load files for a specific category
class LoadFiles extends FilesEvent {
  final FileType? category;

  const LoadFiles({this.category});

  @override
  List<Object?> get props => [category];
}

/// Change the selected category
class ChangeCategory extends FilesEvent {
  final FileType category;

  const ChangeCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Search files by query
class SearchFiles extends FilesEvent {
  final String query;

  const SearchFiles(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear search and show all files
class ClearSearch extends FilesEvent {
  const ClearSearch();
}

/// Delete a file
class DeleteFile extends FilesEvent {
  final String fileId;

  const DeleteFile(this.fileId);

  @override
  List<Object?> get props => [fileId];
}

/// Refresh files list
class RefreshFiles extends FilesEvent {
  const RefreshFiles();
}
