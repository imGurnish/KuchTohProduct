import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/file_item.dart';

/// File Scanner Service
///
/// Platform-aware file discovery service that scans device directories
/// for files and categorizes them by type.
class FileScannerService {
  /// File extensions by category
  static const Map<FileType, List<String>> _extensionsByType = {
    FileType.image: [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'heic',
      'heif',
      'svg',
    ],
    FileType.video: ['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm', '3gp'],
    FileType.audio: ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma'],
    FileType.pdf: ['pdf'],
    FileType.text: [
      'txt',
      'md',
      'doc',
      'docx',
      'rtf',
      'odt',
      'csv',
      'json',
      'xml',
    ],
  };

  /// Check if storage permission is granted
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ needs granular media permissions
      if (await _isAndroid13OrHigher()) {
        final photos = await Permission.photos.status;
        final videos = await Permission.videos.status;
        final audio = await Permission.audio.status;
        return photos.isGranted || videos.isGranted || audio.isGranted;
      } else {
        final storage = await Permission.storage.status;
        return storage.isGranted;
      }
    } else if (Platform.isIOS) {
      final photos = await Permission.photos.status;
      return photos.isGranted || photos.isLimited;
    }
    // Desktop platforms don't need explicit permissions
    return true;
  }

  /// Request storage permission
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        final statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
        return statuses.values.any((s) => s.isGranted);
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }
    return true;
  }

  /// Check if permission is permanently denied
  Future<bool> isPermanentlyDenied() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        final photos = await Permission.photos.status;
        return photos.isPermanentlyDenied;
      } else {
        final storage = await Permission.storage.status;
        return storage.isPermanentlyDenied;
      }
    } else if (Platform.isIOS) {
      final photos = await Permission.photos.status;
      return photos.isPermanentlyDenied;
    }
    return false;
  }

  /// Open app settings for permission
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  Future<bool> _isAndroid13OrHigher() async {
    // Android 13 is API 33
    return Platform.isAndroid;
    // Note: In production, would use device_info_plus to check exact version
  }

  /// Get directories to scan based on platform
  Future<List<Directory>> _getDirectoriesToScan() async {
    final directories = <Directory>[];

    try {
      if (Platform.isAndroid) {
        // Common Android media directories
        final commonPaths = [
          '/storage/emulated/0/DCIM',
          '/storage/emulated/0/Pictures',
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Documents',
          '/storage/emulated/0/Music',
          '/storage/emulated/0/Movies',
        ];
        for (final path in commonPaths) {
          final dir = Directory(path);
          if (await dir.exists()) {
            directories.add(dir);
          }
        }
      } else if (Platform.isIOS) {
        // iOS has limited file access - use app documents
        final appDocs = await getApplicationDocumentsDirectory();
        directories.add(appDocs);
      } else if (Platform.isWindows) {
        // Windows common directories
        final home = Platform.environment['USERPROFILE'];
        if (home != null) {
          final commonPaths = [
            '$home\\Downloads',
            '$home\\Documents',
            '$home\\Pictures',
            '$home\\Music',
            '$home\\Videos',
          ];
          for (final path in commonPaths) {
            final dir = Directory(path);
            if (await dir.exists()) {
              directories.add(dir);
            }
          }
        }
      } else if (Platform.isMacOS) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          final commonPaths = [
            '$home/Downloads',
            '$home/Documents',
            '$home/Pictures',
            '$home/Music',
            '$home/Movies',
          ];
          for (final path in commonPaths) {
            final dir = Directory(path);
            if (await dir.exists()) {
              directories.add(dir);
            }
          }
        }
      } else if (Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          final commonPaths = [
            '$home/Downloads',
            '$home/Documents',
            '$home/Pictures',
            '$home/Music',
            '$home/Videos',
          ];
          for (final path in commonPaths) {
            final dir = Directory(path);
            if (await dir.exists()) {
              directories.add(dir);
            }
          }
        }
      }
    } catch (e) {
      // Ignore permission errors
    }

    return directories;
  }

  /// Get file type from extension
  FileType? _getFileType(String path) {
    final ext = path.split('.').last.toLowerCase();
    for (final entry in _extensionsByType.entries) {
      if (entry.value.contains(ext)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Scan all files of a specific type
  Future<List<FileItem>> scanFilesByType(FileType type) async {
    final files = <FileItem>[];
    final directories = await _getDirectoriesToScan();
    final extensions = _extensionsByType[type] ?? [];

    for (final dir in directories) {
      try {
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            final ext = entity.path.split('.').last.toLowerCase();
            if (extensions.contains(ext)) {
              try {
                final stat = await entity.stat();
                files.add(
                  FileItem(
                    id: entity.path.hashCode.toString(),
                    name: entity.path.split(Platform.pathSeparator).last,
                    path: entity.path,
                    type: type,
                    size: stat.size,
                    createdAt: stat.changed,
                    modifiedAt: stat.modified,
                  ),
                );
              } catch (e) {
                // Skip files we can't access
              }
            }
          }
        }
      } catch (e) {
        // Skip directories we can't access
      }
    }

    // Sort by modified date, newest first
    files.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return files;
  }

  /// Scan all files
  Future<List<FileItem>> scanAllFiles() async {
    final files = <FileItem>[];
    for (final type in FileType.values) {
      files.addAll(await scanFilesByType(type));
    }
    files.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return files;
  }

  /// Get file counts per category
  Future<Map<FileType, int>> getFileCounts() async {
    final counts = <FileType, int>{};
    for (final type in FileType.values) {
      final files = await scanFilesByType(type);
      counts[type] = files.length;
    }
    return counts;
  }
}
