import '../../../../core/utils/typedefs.dart';
import '../entities/message.dart';
import '../entities/conversation.dart';

/// Chat Repository Interface
///
/// Abstract contract for chat operations with session management.
abstract class ChatRepository {
  /// Get all conversations
  ResultFuture<List<Conversation>> getConversations();

  /// Get or create current conversation
  ResultFuture<Conversation> getCurrentConversation();

  /// Create a new conversation
  ResultFuture<Conversation> createConversation();

  /// Switch to a different conversation
  ResultFuture<void> switchConversation(String conversationId);

  /// Delete a conversation
  ResultFuture<void> deleteConversation(String conversationId);

  /// Get all messages for current conversation
  ResultFuture<List<Message>> getMessages();

  /// Send a message and get AI response
  ResultFuture<Message> sendMessage(String content);

  /// Clear messages in current conversation
  ResultVoid clearChat();
}
