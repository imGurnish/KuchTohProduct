import '../../domain/entities/conversation.dart';

/// Conversation Model
///
/// Data model for Conversation with serialization support.
class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
    super.messageCount,
  });

  /// Create from JSON map
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messageCount: json['messageCount'] as int? ?? 0,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messageCount': messageCount,
    };
  }

  /// Create from domain entity
  factory ConversationModel.fromEntity(Conversation entity) {
    return ConversationModel(
      id: entity.id,
      title: entity.title,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      messageCount: entity.messageCount,
    );
  }
}
