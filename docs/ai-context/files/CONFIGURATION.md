# Files Configuration

## Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  # File system access
  permission_handler: ^11.3.1
  path_provider: ^2.1.4
  
  # Thumbnails
  video_thumbnail: ^0.5.3
  
  # Caching
  shared_preferences: ^2.3.3
  
  # Date formatting
  intl: ^0.19.0
```

## Android Setup

### 1. Update minimum SDK

In `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        compileSdk 34
    }
}
```

### 2. Add permissions

In `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <!-- Storage permissions -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="32"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="29"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>

    <application
        android:requestLegacyExternalStorage="true">
        <!-- ... -->
    </application>
</manifest>
```

## iOS Setup

In `ios/Runner/Info.plist`:

```xml
<dict>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Mindspace needs access to your photos and files.</string>
</dict>
```

## Dependency Injection

In `lib/core/di/injection_container.dart`:

```dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void initFilesFeature() {
  // Services
  sl.registerLazySingleton<FileScannerService>(
    () => FileScannerService(),
  );

  // Data Sources
  sl.registerLazySingleton<FilesLocalDataSource>(
    () => FilesLocalDataSourceImpl(scanner: sl<FileScannerService>()),
  );

  // Repositories
  sl.registerLazySingleton<FilesRepository>(
    () => FilesRepositoryImpl(dataSource: sl<FilesLocalDataSource>()),
  );

  // BLoC
  sl.registerFactory<FilesBloc>(
    () => FilesBloc(filesRepository: sl<FilesRepository>()),
  );
}
```

## Cache Configuration

```dart
// In FilesLocalDataSourceImpl
class FilesLocalDataSourceImpl {
  // Cache TTL - files are rescanned after this duration
  static const _cacheDuration = Duration(hours: 24);
  
  // Key prefix for SharedPreferences
  static const _cacheKeyPrefix = 'files_cache_';
  static const _lastScanKey = 'files_last_scan';
}
```

### Modifying Cache Duration

To change cache TTL, update `_cacheDuration`:

```dart
// Shorter cache for development
static const _cacheDuration = Duration(minutes: 30);

// Longer cache for production
static const _cacheDuration = Duration(days: 7);
```

## Adding New File Types

### 1. Add to FileType enum

```dart
// In file_item.dart
enum FileType { 
  image, video, audio, pdf, text, 
  archive  // New type
}
```

### 2. Add display properties

```dart
extension FileTypeExtension on FileType {
  String get displayName {
    switch (this) {
      case FileType.archive: return 'Archives';
      // ...
    }
  }
}
```

### 3. Add extensions to scanner

```dart
// In file_scanner_service.dart
static const Map<FileType, List<String>> _extensionsByType = {
  FileType.archive: ['zip', 'rar', '7z', 'tar', 'gz'],
  // ...
};
```

### 4. Add icon and color

```dart
// In category_card.dart and file_card.dart
IconData get _icon {
  case FileType.archive: return Icons.folder_zip_rounded;
}

Color get _color {
  case FileType.archive: return Colors.brown;
}
```

## Thumbnail Configuration

### Video Thumbnail Settings

```dart
// In file_card.dart
final thumb = await VideoThumbnail.thumbnailData(
  video: filePath,
  imageFormat: ImageFormat.JPEG,
  maxWidth: 300,      // Max width in pixels
  quality: 50,        // JPEG quality (0-100)
);
```

### Image Thumbnail Settings

```dart
// In file_card.dart
Image.file(
  File(filePath),
  cacheWidth: 300,   // Memory-efficient loading
  fit: BoxFit.cover,
);
```
