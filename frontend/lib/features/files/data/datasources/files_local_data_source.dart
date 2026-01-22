import '../../domain/entities/file_item.dart';
import '../models/file_item_model.dart';

/// Files Local Data Source Interface
abstract class FilesLocalDataSource {
  /// Get files by category type
  Future<List<FileItemModel>> getFilesByCategory(FileType type);

  /// Get all files
  Future<List<FileItemModel>> getAllFiles();

  /// Get count of files per category
  Future<Map<FileType, int>> getFileCounts();

  /// Delete a file
  Future<void> deleteFile(String id);
}

/// Mock implementation for testing UI
class FilesLocalDataSourceImpl implements FilesLocalDataSource {
  // Mock data for development
  final List<FileItemModel> _mockFiles = [
    // Images
    FileItemModel(
      id: '1',
      name: 'vacation_photo.jpg',
      path: '/storage/images/vacation_photo.jpg',
      type: FileType.image,
      size: 2500000,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      modifiedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    FileItemModel(
      id: '2',
      name: 'screenshot_2024.png',
      path: '/storage/images/screenshot_2024.png',
      type: FileType.image,
      size: 850000,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      modifiedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FileItemModel(
      id: '3',
      name: 'profile_picture.jpg',
      path: '/storage/images/profile_picture.jpg',
      type: FileType.image,
      size: 1200000,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      modifiedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    // Videos
    FileItemModel(
      id: '4',
      name: 'birthday_party.mp4',
      path: '/storage/videos/birthday_party.mp4',
      type: FileType.video,
      size: 150000000,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      modifiedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    FileItemModel(
      id: '5',
      name: 'tutorial_flutter.mp4',
      path: '/storage/videos/tutorial_flutter.mp4',
      type: FileType.video,
      size: 85000000,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      modifiedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    // Audio
    FileItemModel(
      id: '6',
      name: 'podcast_episode_42.mp3',
      path: '/storage/audio/podcast_episode_42.mp3',
      type: FileType.audio,
      size: 45000000,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      modifiedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    FileItemModel(
      id: '7',
      name: 'voice_memo.m4a',
      path: '/storage/audio/voice_memo.m4a',
      type: FileType.audio,
      size: 2500000,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      modifiedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    // PDFs
    FileItemModel(
      id: '8',
      name: 'meeting_notes.pdf',
      path: '/storage/documents/meeting_notes.pdf',
      type: FileType.pdf,
      size: 520000,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      modifiedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FileItemModel(
      id: '9',
      name: 'flutter_guide.pdf',
      path: '/storage/documents/flutter_guide.pdf',
      type: FileType.pdf,
      size: 8500000,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      modifiedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    // Text files
    FileItemModel(
      id: '10',
      name: 'todo_list.txt',
      path: '/storage/text/todo_list.txt',
      type: FileType.text,
      size: 2500,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      modifiedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    FileItemModel(
      id: '11',
      name: 'shopping_list.txt',
      path: '/storage/text/shopping_list.txt',
      type: FileType.text,
      size: 1200,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      modifiedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  @override
  Future<List<FileItemModel>> getFilesByCategory(FileType type) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockFiles.where((file) => file.type == type).toList();
  }

  @override
  Future<List<FileItemModel>> getAllFiles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockFiles);
  }

  @override
  Future<Map<FileType, int>> getFileCounts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final counts = <FileType, int>{};
    for (final type in FileType.values) {
      counts[type] = _mockFiles.where((f) => f.type == type).length;
    }
    return counts;
  }

  @override
  Future<void> deleteFile(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockFiles.removeWhere((file) => file.id == id);
  }
}
