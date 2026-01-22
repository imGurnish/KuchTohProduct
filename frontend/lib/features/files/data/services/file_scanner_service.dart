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
      'tiff',
      'ico',
    ],
    FileType.video: [
      'mp4',
      'mov',
      'avi',
      'mkv',
      'wmv',
      'flv',
      'webm',
      '3gp',
      'm4v',
      'mpeg',
      'mpg',
    ],
    FileType.audio: [
      'mp3',
      'wav',
      'aac',
      'flac',
      'ogg',
      'm4a',
      'wma',
      'opus',
      'aiff',
    ],
    FileType.pdf: ['pdf'],
    FileType.text: [
      'txt',
      'md',
      'markdown',
      'doc',
      'docx',
      'rtf',
      'odt',
      'csv',
      'json',
      'xml',
      'html',
      'htm',
      'log',
      'ini',
      'cfg',
      'yaml',
      'yml',
      'pptx',
      'ppt',
      'xlsx',
      'xls',
    ],
  };

  /// Check if storage permission is granted
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      // Check for manage external storage (full access) first
      final manageStorage = await Permission.manageExternalStorage.status;
      if (manageStorage.isGranted) return true;

      // Fallback to media permissions
      final photos = await Permission.photos.status;
      final videos = await Permission.videos.status;
      final audio = await Permission.audio.status;
      final storage = await Permission.storage.status;

      return photos.isGranted ||
          videos.isGranted ||
          audio.isGranted ||
          storage.isGranted;
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
      // First try to get manage external storage (for full document access)
      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) return true;

      // Fallback: request media permissions
      final statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.audio,
        Permission.storage,
      ].request();
      return statuses.values.any((s) => s.isGranted);
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }
    return true;
  }

  /// Check if permission is permanently denied
  Future<bool> isPermanentlyDenied() async {
    if (Platform.isAndroid) {
      final manage = await Permission.manageExternalStorage.status;
      final photos = await Permission.photos.status;
      final storage = await Permission.storage.status;
      // Only permanently denied if ALL are denied
      return manage.isPermanentlyDenied &&
          photos.isPermanentlyDenied &&
          storage.isPermanentlyDenied;
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

  /// Get directories to scan based on platform
  Future<List<Directory>> _getDirectoriesToScan() async {
    final directories = <Directory>[];

    try {
      if (Platform.isAndroid) {
        // Comprehensive Android directories
        final basePaths = [
          '/storage/emulated/0/DCIM',
          '/storage/emulated/0/Pictures',
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Downloads',
          '/storage/emulated/0/Documents',
          '/storage/emulated/0/Music',
          '/storage/emulated/0/Movies',
          '/storage/emulated/0/WhatsApp/Media',
          '/storage/emulated/0/Telegram',
        ];

        for (final path in basePaths) {
          final dir = Directory(path);
          if (await dir.exists()) {
            directories.add(dir);
          }
        }

        // Also try app-specific external storage
        try {
          final externalDirs = await getExternalStorageDirectories();
          if (externalDirs != null) {
            for (final dir in externalDirs) {
              if (await dir.exists()) {
                directories.add(dir);
              }
            }
          }
        } catch (e) {
          // Ignore if not available
        }
      } else if (Platform.isIOS) {
        // iOS app documents
        final appDocs = await getApplicationDocumentsDirectory();
        directories.add(appDocs);

        // Try downloads on iOS
        try {
          final downloadsDir = await getDownloadsDirectory();
          if (downloadsDir != null && await downloadsDir.exists()) {
            directories.add(downloadsDir);
          }
        } catch (e) {
          // Downloads may not be available
        }
      } else if (Platform.isWindows) {
        final home = Platform.environment['USERPROFILE'];
        if (home != null) {
          final commonPaths = [
            '$home\\Downloads',
            '$home\\Documents',
            '$home\\Pictures',
            '$home\\Music',
            '$home\\Videos',
            '$home\\Desktop',
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
            '$home/Desktop',
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
            '$home/Desktop',
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
                // Verify file is readable and has content
                if (stat.size > 0) {
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
                }
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

    // Remove duplicates (same path)
    final seen = <String>{};
    files.retainWhere((f) => seen.add(f.path));

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
