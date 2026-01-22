import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Get files by category (from cache or scan)
  Future<List<FileItemModel>> getFilesByCategory(FileType type);

  /// Get all files
  Future<List<FileItemModel>> getAllFiles();

  /// Get file counts per category
  Future<Map<FileType, int>> getFileCounts();

  /// Delete a file
  Future<void> deleteFile(String id);

  /// Force refresh - rescan files
  Future<void> forceRefresh();
}

/// Real implementation with persistent caching
class FilesLocalDataSourceImpl implements FilesLocalDataSource {
  final FileScannerService _scanner;
  SharedPreferences? _prefs;

  // In-memory cache
  Map<FileType, List<FileItemModel>>? _memoryCache;

  // Cache keys
  static const _cacheKeyPrefix = 'files_cache_';
  static const _lastScanKey = 'files_last_scan';
  static const _cacheDuration = Duration(hours: 24);

  FilesLocalDataSourceImpl({FileScannerService? scanner})
    : _scanner = scanner ?? FileScannerService();

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Check if cache is valid (less than 24 hours old)
  Future<bool> _isCacheValid() async {
    final prefs = await _preferences;
    final lastScanStr = prefs.getString(_lastScanKey);
    if (lastScanStr == null) return false;

    final lastScan = DateTime.tryParse(lastScanStr);
    if (lastScan == null) return false;

    return DateTime.now().difference(lastScan) < _cacheDuration;
  }

  /// Load files from persistent cache
  Future<List<FileItemModel>?> _loadFromCache(FileType type) async {
    final prefs = await _preferences;
    final key = '$_cacheKeyPrefix${type.name}';
    final jsonStr = prefs.getString(key);

    if (jsonStr == null) return null;

    try {
      final List<dynamic> jsonList = json.decode(jsonStr);
      return jsonList.map((j) => FileItemModel.fromJson(j)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Save files to persistent cache
  Future<void> _saveToCache(FileType type, List<FileItemModel> files) async {
    final prefs = await _preferences;
    final key = '$_cacheKeyPrefix${type.name}';
    final jsonList = files.map((f) => f.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
    await prefs.setString(_lastScanKey, DateTime.now().toIso8601String());
  }

  /// Clear all cached data
  Future<void> _clearCache() async {
    final prefs = await _preferences;
    for (final type in FileType.values) {
      await prefs.remove('$_cacheKeyPrefix${type.name}');
    }
    await prefs.remove(_lastScanKey);
    _memoryCache = null;
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
    // 1. Check memory cache first (fastest)
    if (_memoryCache != null && _memoryCache!.containsKey(type)) {
      return _memoryCache![type]!;
    }

    // 2. Check persistent cache
    final isCacheValid = await _isCacheValid();
    if (isCacheValid) {
      final cachedFiles = await _loadFromCache(type);
      if (cachedFiles != null && cachedFiles.isNotEmpty) {
        _memoryCache ??= {};
        _memoryCache![type] = cachedFiles;
        return cachedFiles;
      }
    }

    // 3. Scan file system (slow, only when cache is invalid)
    return await _scanAndCache(type);
  }

  /// Scan files and cache results
  Future<List<FileItemModel>> _scanAndCache(FileType type) async {
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

    // Update caches
    _memoryCache ??= {};
    _memoryCache![type] = models;
    await _saveToCache(type, models);

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
    if (_memoryCache != null) {
      for (final entry in _memoryCache!.entries) {
        try {
          final file = entry.value.firstWhere((f) => f.id == id);
          final fileEntity = File(file.path);
          if (await fileEntity.exists()) {
            await fileEntity.delete();
          }
          // Clear cache to force refresh
          await _clearCache();
          return;
        } catch (e) {
          // File not found in this category, continue
        }
      }
    }
    throw Exception('File not found');
  }

  @override
  Future<void> forceRefresh() async {
    await _clearCache();
  }
}
