import 'dart:io';
import '../../domain/entities/file_item.dart';
import '../models/file_item_model.dart';
import '../services/file_scanner_service.dart';

/// Files Local Data Source Interface
abstract class FilesLocalDataSource {
  /// Check if storage permission is granted
  Future<bool> hasPermission();

  /// Request storage permission
  Future<bool> requestPermission();

  /// Check if permission is permanently denied
  Future<bool> isPermanentlyDenied();

  /// Open app settings
  Future<bool> openSettings();

  /// Get files by category
  Future<List<FileItemModel>> getFilesByCategory(FileType type);

  /// Get all files
  Future<List<FileItemModel>> getAllFiles();

  /// Get file counts per category
  Future<Map<FileType, int>> getFileCounts();

  /// Delete a file
  Future<void> deleteFile(String id);
}

/// Real implementation using file scanner
class FilesLocalDataSourceImpl implements FilesLocalDataSource {
  final FileScannerService _scanner;

  // Cache for performance
  Map<FileType, List<FileItemModel>>? _cache;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  FilesLocalDataSourceImpl({FileScannerService? scanner})
    : _scanner = scanner ?? FileScannerService();

  bool get _isCacheValid =>
      _cache != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheDuration;

  void _invalidateCache() {
    _cache = null;
    _cacheTime = null;
  }

  @override
  Future<bool> hasPermission() => _scanner.hasPermission();

  @override
  Future<bool> requestPermission() => _scanner.requestPermission();

  @override
  Future<bool> isPermanentlyDenied() => _scanner.isPermanentlyDenied();

  @override
  Future<bool> openSettings() => _scanner.openSettings();

  @override
  Future<List<FileItemModel>> getFilesByCategory(FileType type) async {
    // Check cache first
    if (_isCacheValid && _cache!.containsKey(type)) {
      return _cache![type]!;
    }

    final files = await _scanner.scanFilesByType(type);
    final models = files
        .map(
          (f) => FileItemModel(
            id: f.id,
            name: f.name,
            path: f.path,
            type: f.type,
            size: f.size,
            createdAt: f.createdAt,
            modifiedAt: f.modifiedAt,
          ),
        )
        .toList();

    // Update cache
    _cache ??= {};
    _cache![type] = models;
    _cacheTime = DateTime.now();

    return models;
  }

  @override
  Future<List<FileItemModel>> getAllFiles() async {
    final allFiles = <FileItemModel>[];
    for (final type in FileType.values) {
      allFiles.addAll(await getFilesByCategory(type));
    }
    allFiles.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return allFiles;
  }

  @override
  Future<Map<FileType, int>> getFileCounts() async {
    final counts = <FileType, int>{};
    for (final type in FileType.values) {
      final files = await getFilesByCategory(type);
      counts[type] = files.length;
    }
    return counts;
  }

  @override
  Future<void> deleteFile(String id) async {
    // Find the file in cache
    if (_cache != null) {
      for (final entry in _cache!.entries) {
        final file = entry.value.firstWhere(
          (f) => f.id == id,
          orElse: () => throw Exception('File not found'),
        );

        try {
          final fileEntity = File(file.path);
          if (await fileEntity.exists()) {
            await fileEntity.delete();
          }
          _invalidateCache();
          return;
        } catch (e) {
          throw Exception('Failed to delete file: $e');
        }
      }
    }
    throw Exception('File not found');
  }
}
