part of 'files_bloc.dart';

/// Files BLoC Events
abstract class FilesEvent extends Equatable {
  const FilesEvent();

  @override
  List<Object?> get props => [];
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
