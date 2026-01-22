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

/// Load initial data (counts only for home view)
class LoadInitialData extends FilesEvent {
  const LoadInitialData();
}

/// Open a specific category
class OpenCategory extends FilesEvent {
  final FileType category;

  const OpenCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Go back to home view
class GoBackToHome extends FilesEvent {
  const GoBackToHome();
}

/// Search files across ALL categories
class SearchAllFiles extends FilesEvent {
  final String query;

  const SearchAllFiles(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear search and return to previous view
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

/// Refresh current view
class RefreshFiles extends FilesEvent {
  const RefreshFiles();
}
