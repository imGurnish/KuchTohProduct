# Files Platform Support

## Android

### Permissions Required

```xml
<!-- AndroidManifest.xml -->

<!-- Android 12 and below -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="29"/>

<!-- Android 13+ granular media permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>

<!-- Full storage access for documents/PDFs (Android 11+) -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>

<application
    android:requestLegacyExternalStorage="true">
```

### Permission Flow

```
┌─────────────────────────────────────────────────────────┐
│                    ANDROID 13+ (API 33+)                 │
├─────────────────────────────────────────────────────────┤
│ Media Files (images, videos, audio):                     │
│   → READ_MEDIA_* permissions                             │
│   → Standard permission dialog                           │
├─────────────────────────────────────────────────────────┤
│ Documents (PDFs, text files):                            │
│   → MANAGE_EXTERNAL_STORAGE                              │
│   → Redirects to Settings → "All Files Access"           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    ANDROID 11-12 (API 30-32)            │
├─────────────────────────────────────────────────────────┤
│ All Files:                                               │
│   → READ_EXTERNAL_STORAGE + MANAGE_EXTERNAL_STORAGE     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    ANDROID 10 (API 29)                   │
├─────────────────────────────────────────────────────────┤
│ All Files:                                               │
│   → requestLegacyExternalStorage="true"                  │
│   → READ_EXTERNAL_STORAGE                                │
└─────────────────────────────────────────────────────────┘
```

### Scanned Directories

| Directory | Content |
|-----------|---------|
| `/storage/emulated/0/DCIM` | Camera photos/videos |
| `/storage/emulated/0/Pictures` | Saved images |
| `/storage/emulated/0/Download` | Downloaded files |
| `/storage/emulated/0/Documents` | Documents, PDFs |
| `/storage/emulated/0/Music` | Audio files |
| `/storage/emulated/0/Movies` | Video files |
| `/storage/emulated/0/WhatsApp/Media` | WhatsApp media |

---

## iOS

### Info.plist Configuration

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Mindspace needs access to your photos to display and manage them.</string>
```

### Limitations

- iOS apps are sandboxed
- Only access to app documents and photo library
- No direct file system access like Android

### Scanned Directories

| Directory | Access |
|-----------|--------|
| App Documents | Full access via path_provider |
| Downloads | Limited access |
| Photo Library | Via photos permission |

---

## Windows

### No Permission Required

Windows desktop apps have full user directory access via `dart:io`.

### Scanned Directories

| Directory | Path |
|-----------|------|
| Downloads | `%USERPROFILE%\Downloads` |
| Documents | `%USERPROFILE%\Documents` |
| Pictures | `%USERPROFILE%\Pictures` |
| Music | `%USERPROFILE%\Music` |
| Videos | `%USERPROFILE%\Videos` |
| Desktop | `%USERPROFILE%\Desktop` |

---

## macOS

### Entitlements

For sandboxed apps, may need entitlements in `macos/Runner/DebugProfile.entitlements`:

```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

### Scanned Directories

| Directory | Path |
|-----------|------|
| Downloads | `~/Downloads` |
| Documents | `~/Documents` |
| Pictures | `~/Pictures` |
| Music | `~/Music` |
| Movies | `~/Movies` |
| Desktop | `~/Desktop` |

---

## Linux

### No Permission Required

Linux desktop apps have standard user directory access.

### Scanned Directories

Same as macOS (`~/Downloads`, `~/Documents`, etc.)

---

## Permission Handler Usage

```dart
// Check permission
final hasPermission = await Permission.manageExternalStorage.isGranted;

// Request permission
final status = await Permission.manageExternalStorage.request();

// Check if permanently denied
final isPermanent = await Permission.manageExternalStorage.isPermanentlyDenied;

// Open settings
await openAppSettings();
```
