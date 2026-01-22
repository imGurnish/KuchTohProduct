import 'package:equatable/equatable.dart';

/// Message role in a conversation
enum MessageRole { user, assistant }

/// Message Entity
///
/// Represents a single message in a chat conversation.
class Message extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final List<String>? attachmentIds;
  final bool isLoading;

  const Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.attachmentIds,
    this.isLoading = false,
  });

  /// Check if message is from user
  bool get isUser => role == MessageRole.user;

  /// Check if message is from assistant
  bool get isAssistant => role == MessageRole.assistant;

  /// Get formatted time string
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  List<Object?> get props => [
    id,
    content,
    role,
    timestamp,
    attachmentIds,
    isLoading,
  ];

  Message copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    List<String>? attachmentIds,
    bool? isLoading,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
