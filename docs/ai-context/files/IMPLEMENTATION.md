# Files Implementation Guide

## FileItem Entity

```dart
enum FileType { image, video, audio, pdf, text }

class FileItem extends Equatable {
  final String id;
  final String name;
  final String path;
  final FileType type;
  final int size;
  final DateTime createdAt;
  final DateTime modifiedAt;

  String get extension => path.split('.').last.toLowerCase();
  String get formattedSize => _formatBytes(size);
}
```

## File Extensions Mapping

| FileType | Extensions |
|----------|-----------|
| image | jpg, jpeg, png, gif, webp, bmp, heic, heif, svg, tiff, ico |
| video | mp4, mov, avi, mkv, wmv, flv, webm, 3gp, m4v, mpeg, mpg |
| audio | mp3, wav, aac, flac, ogg, m4a, wma, opus, aiff |
| pdf | pdf |
| text | txt, md, doc, docx, rtf, odt, csv, json, xml, html, htm, log, ini, cfg, yaml, yml, pptx, ppt, xlsx, xls |

## FileScannerService

Platform-aware file discovery:

```dart
class FileScannerService {
  /// Scan directories based on platform
  Future<List<Directory>> _getDirectoriesToScan() async {
    if (Platform.isAndroid) {
      return [
        Directory('/storage/emulated/0/DCIM'),
        Directory('/storage/emulated/0/Pictures'),
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Documents'),
        Directory('/storage/emulated/0/Music'),
        Directory('/storage/emulated/0/Movies'),
      ];
    } else if (Platform.isWindows) {
      final home = Platform.environment['USERPROFILE'];
      return [
        Directory('$home\\Downloads'),
        Directory('$home\\Documents'),
        Directory('$home\\Pictures'),
        // ...
      ];
    }
    // Similar for iOS, macOS, Linux
  }

  /// Scan files by type with extension filtering
  Future<List<FileItem>> scanFilesByType(FileType type) async {
    final files = <FileItem>[];
    final dirs = await _getDirectoriesToScan();
    final extensions = _extensionsByType[type];

    for (final dir in dirs) {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final ext = entity.path.split('.').last.toLowerCase();
          if (extensions.contains(ext)) {
            final stat = await entity.stat();
            files.add(FileItem(...));
          }
        }
      }
    }
    return files;
  }
}
```

## FilesLocalDataSource

Caching layer with 24-hour TTL:

```dart
class FilesLocalDataSourceImpl implements FilesLocalDataSource {
  // Memory cache
  Map<FileType, List<FileItemModel>>? _memoryCache;
  
  // Cache keys
  static const _cacheKeyPrefix = 'files_cache_';
  static const _lastScanKey = 'files_last_scan';
  static const _cacheDuration = Duration(hours: 24);

  Future<List<FileItemModel>> getFilesByCategory(FileType type) async {
    // 1. Check memory cache
    if (_memoryCache?[type] != null) return _memoryCache![type]!;
    
    // 2. Check persistent cache
    if (await _isCacheValid()) {
      final cached = await _loadFromCache(type);
      if (cached != null) return cached;
    }
    
    // 3. Scan file system
    return await _scanAndCache(type);
  }

  Future<void> forceRefresh() async {
    await _clearCache();  // Clears both memory and persistent
  }
}
```

## FilesBloc Events

| Event | Description |
|-------|-------------|
| `CheckPermission` | Initial permission check |
| `RequestPermission` | Request storage access |
| `OpenSettings` | Open app settings |
| `LoadInitialData` | Load category counts for home |
| `OpenCategory(type)` | Navigate to category view |
| `GoBackToHome` | Return to home view |
| `SearchAllFiles(query)` | Global search |
| `ClearSearch` | Exit search mode |
| `DeleteFile(id)` | Delete file |
| `RefreshFiles` | Force cache clear and rescan |

## FilesBloc Implementation

```dart
class FilesBloc extends Bloc<FilesEvent, FilesState> {
  List<FileItem> _allFilesCache = [];  // For search

  Future<void> _onOpenCategory(OpenCategory event, emit) async {
    emit(FilesLoading());
    final result = await _filesRepository.getFilesByCategory(event.category);
    result.fold(
      (failure) => emit(FilesError(failure.message)),
      (files) => emit(FilesReady(
        viewMode: FilesViewMode.category,
        files: files,
        selectedCategory: event.category,
      )),
    );
  }

  Future<void> _onSearchAllFiles(SearchAllFiles event, emit) async {
    // Load all files if not cached
    if (_allFilesCache.isEmpty) {
      final result = await _filesRepository.getAllFiles();
      result.fold((_) => null, (files) => _allFilesCache = files);
    }
    
    // Filter by name/extension
    final filtered = _allFilesCache.where((f) =>
      f.name.toLowerCase().contains(event.query.toLowerCase())
    ).toList();
    
    emit(state.copyWith(
      viewMode: FilesViewMode.search,
      files: filtered,
      searchQuery: event.query,
    ));
  }
}
```

## UI Widgets

### CategoryCard

```dart
class CategoryCard extends StatelessWidget {
  final FileType type;
  final int count;
  final VoidCallback onTap;

  // Returns colored icon based on type
  // Images: green, Videos: blue, Audio: pink, PDF: red, Text: yellow
}
```

### FileCard (Minimal)

```dart
class FileCard extends StatelessWidget {
  final FileItem file;

  Widget build(context) {
    return Column(
      children: [
        Expanded(child: _buildThumbnail()),  // Image/Video thumb or icon
        Text(file.name),  // Name only, no metadata
      ],
    );
  }
}
```

### FileDetailSheet

```dart
class FileDetailSheet extends StatelessWidget {
  // Shows full metadata:
  // - File name and type icon
  // - Size, Created date, Modified date
  // - Extension, Full path
  // - Delete action
}
```

## Responsive Grid

```dart
int crossAxisCount = 2;  // Mobile
if (width > 600) crossAxisCount = 3;   // Tablet
if (width > 900) crossAxisCount = 4;   // Small desktop
if (width > 1200) crossAxisCount = 6;  // Large desktop
```
