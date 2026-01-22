import '../../domain/entities/file_item.dart';

/// File Item Model
///
/// Data model extending FileItem entity for serialization and data source interaction.
class FileItemModel extends FileItem {
  const FileItemModel({
    required super.id,
    required super.name,
    required super.path,
    required super.type,
    required super.size,
    super.thumbnailPath,
    required super.createdAt,
    required super.modifiedAt,
  });

  /// Create from JSON map
  factory FileItemModel.fromJson(Map<String, dynamic> json) {
    return FileItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: FileType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FileType.text,
      ),
      size: json['size'] as int,
      thumbnailPath: json['thumbnailPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type.name,
      'size': size,
      'thumbnailPath': thumbnailPath,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }

  /// Create from domain entity
  factory FileItemModel.fromEntity(FileItem entity) {
    return FileItemModel(
      id: entity.id,
      name: entity.name,
      path: entity.path,
      type: entity.type,
      size: entity.size,
      thumbnailPath: entity.thumbnailPath,
      createdAt: entity.createdAt,
      modifiedAt: entity.modifiedAt,
    );
  }
}
