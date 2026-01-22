import 'package:equatable/equatable.dart';

/// File type categories
enum FileType { image, video, audio, pdf, text }

/// Extension to get display properties for FileType
extension FileTypeExtension on FileType {
  String get displayName {
    switch (this) {
      case FileType.image:
        return 'Images';
      case FileType.video:
        return 'Videos';
      case FileType.audio:
        return 'Audio';
      case FileType.pdf:
        return 'PDFs';
      case FileType.text:
        return 'Text';
    }
  }

  String get iconName {
    switch (this) {
      case FileType.image:
        return 'image';
      case FileType.video:
        return 'video_library';
      case FileType.audio:
        return 'audiotrack';
      case FileType.pdf:
        return 'picture_as_pdf';
      case FileType.text:
        return 'description';
    }
  }
}

/// File Item Entity
///
/// Represents a file stored on the device.
class FileItem extends Equatable {
  final String id;
  final String name;
  final String path;
  final FileType type;
  final int size;
  final String? thumbnailPath;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const FileItem({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    this.thumbnailPath,
    required this.createdAt,
    required this.modifiedAt,
  });

  /// Get formatted file size
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file extension
  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    path,
    type,
    size,
    thumbnailPath,
    createdAt,
    modifiedAt,
  ];
}
