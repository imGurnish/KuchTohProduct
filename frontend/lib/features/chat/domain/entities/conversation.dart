import 'package:equatable/equatable.dart';

/// Conversation Entity
///
/// Represents a chat session/conversation.
class Conversation extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;

  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
  });

  /// Generate a default title from first message
  static String generateTitle(String? firstMessage) {
    if (firstMessage == null || firstMessage.isEmpty) {
      return 'New Chat';
    }
    // Truncate to first 30 chars
    final truncated = firstMessage.length > 30
        ? '${firstMessage.substring(0, 30)}...'
        : firstMessage;
    return truncated;
  }

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt, messageCount];
}
