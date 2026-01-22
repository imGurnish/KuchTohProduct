import '../../domain/entities/message.dart';

/// Message Model
///
/// Data model for Message entity with serialization support.
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.content,
    required super.role,
    required super.timestamp,
    super.attachmentIds,
    super.isLoading,
  });

  /// Create from JSON map
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      attachmentIds: (json['attachmentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'attachmentIds': attachmentIds,
      'isLoading': isLoading,
    };
  }

  /// Create from domain entity
  factory MessageModel.fromEntity(Message entity) {
    return MessageModel(
      id: entity.id,
      content: entity.content,
      role: entity.role,
      timestamp: entity.timestamp,
      attachmentIds: entity.attachmentIds,
      isLoading: entity.isLoading,
    );
  }
}
