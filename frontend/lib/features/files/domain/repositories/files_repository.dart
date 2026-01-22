import '../../../../core/utils/typedefs.dart';
import '../entities/file_item.dart';

/// Files Repository Interface
///
/// Abstract contract for file operations.
abstract class FilesRepository {
  /// Get all files for a specific category
  ResultFuture<List<FileItem>> getFilesByCategory(FileType type);

  /// Get all files across all categories
  ResultFuture<List<FileItem>> getAllFiles();

  /// Get file counts per category
  ResultFuture<Map<FileType, int>> getFileCounts();

  /// Delete a file by ID
  ResultVoid deleteFile(String id);
}
