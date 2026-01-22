# Backup Implementation Roadmap

## Current State

The backup feature currently shows a placeholder screen:

```dart
class BackupsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_rounded, size: 64),
            SizedBox(height: 16),
            Text('Backups', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Coming Soon'),
          ],
        ),
      ),
    );
  }
}
```

## Implementation Phases

### Phase 1: Google Sign-In Integration
- [ ] Add google_sign_in package
- [ ] Configure OAuth credentials
- [ ] Implement sign-in flow for Drive access
- [ ] Request Drive file scope

### Phase 2: Basic Upload
- [ ] Create backup folder in Drive
- [ ] Upload single file
- [ ] Track upload progress
- [ ] Save backup metadata locally

### Phase 3: Full Backup
- [ ] Scan files to backup
- [ ] Calculate file hashes for deduplication
- [ ] Upload only changed files
- [ ] Create backup manifest

### Phase 4: Restore
- [ ] List available backups
- [ ] Download backup manifest
- [ ] Download and restore files
- [ ] Verify file integrity

### Phase 5: Background Sync
- [ ] Schedule periodic backups
- [ ] Handle network changes
- [ ] Battery-aware scheduling
- [ ] Notification for sync status

### Phase 6: UI Polish
- [ ] Sync status indicator
- [ ] Backup history list
- [ ] Storage usage display
- [ ] Settings (frequency, wifi-only, etc.)

## Key Implementation Details

### File Hashing for Deduplication

```dart
import 'dart:io';
import 'package:crypto/crypto.dart';

Future<String> getFileHash(File file) async {
  final bytes = await file.readAsBytes();
  return sha256.convert(bytes).toString();
}
```

### Backup Manifest Structure

```json
{
  "id": "backup_1234567890",
  "createdAt": "2024-01-22T10:30:00Z",
  "files": [
    {
      "path": "/storage/emulated/0/DCIM/photo.jpg",
      "hash": "sha256:abc123...",
      "driveFileId": "drive_abc123",
      "size": 1048576
    }
  ],
  "totalSize": 104857600,
  "fileCount": 100
}
```

### Drive Folder Structure

```
My Drive/
└── Mindspace Backup/
    ├── manifests/
    │   ├── backup_1234567890.json
    │   └── backup_1234567891.json
    └── files/
        ├── sha256_abc123...
        └── sha256_def456...
```

## Testing Plan

1. **Unit Tests**
   - File hashing
   - Manifest creation/parsing
   - Backup logic

2. **Integration Tests**
   - Google Sign-In flow
   - File upload/download
   - Restore process

3. **Manual Testing**
   - Large file handling
   - Network interruption recovery
   - Background sync reliability
