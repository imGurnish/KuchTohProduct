import 'dart:math';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

/// Chat Local Data Source Interface
abstract class ChatLocalDataSource {
  /// Get all conversations
  Future<List<ConversationModel>> getConversations();

  /// Get current conversation (creates one if none exists)
  Future<ConversationModel> getCurrentConversation();

  /// Create a new conversation
  Future<ConversationModel> createConversation();

  /// Switch to a different conversation
  Future<void> switchConversation(String conversationId);

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId);

  /// Get all messages for current conversation
  Future<List<MessageModel>> getMessages();

  /// Add a message to current conversation
  Future<void> addMessage(MessageModel message);

  /// Get AI response (mock)
  Future<MessageModel> getAIResponse(String userMessage);

  /// Clear messages in current conversation
  Future<void> clearMessages();
}

/// Mock implementation for testing UI
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Map<String, List<MessageModel>> _messagesByConversation = {};
  final List<ConversationModel> _conversations = [];
  String? _currentConversationId;
  final _random = Random();

  // Mock AI responses
  final List<String> _mockResponses = [
    'That\'s a great question! Based on your files, I can help you find relevant information. What specifically would you like to know?',
    'I found some related content in your documents. Would you like me to show you the details?',
    'I can see you have several files that might be relevant to this topic. Let me analyze them for you.',
    'Interesting! I\'ve analyzed your request and here\'s what I found in your local files.',
    'I\'m here to help you explore your knowledge base. Would you like me to search for specific topics?',
    'Based on my understanding of your files, here\'s a summary of what I can tell you about that.',
    'Great question! Let me check your documents and provide you with relevant information.',
    'I\'ve scanned your files and found some interesting patterns. Would you like to know more?',
  ];

  @override
  Future<List<ConversationModel>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Sort by updated time, newest first
    final sorted = List<ConversationModel>.from(_conversations)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  @override
  Future<ConversationModel> getCurrentConversation() async {
    if (_currentConversationId == null || _conversations.isEmpty) {
      return createConversation();
    }

    final current = _conversations.firstWhere(
      (c) => c.id == _currentConversationId,
      orElse: () => _conversations.first,
    );
    return current;
  }

  @override
  Future<ConversationModel> createConversation() async {
    await Future.delayed(const Duration(milliseconds: 50));

    final now = DateTime.now();
    final conversation = ConversationModel(
      id: 'conv_${now.millisecondsSinceEpoch}',
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
      messageCount: 0,
    );

    _conversations.insert(0, conversation);
    _messagesByConversation[conversation.id] = [];
    _currentConversationId = conversation.id;

    return conversation;
  }

  @override
  Future<void> switchConversation(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_conversations.any((c) => c.id == conversationId)) {
      _currentConversationId = conversationId;
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _conversations.removeWhere((c) => c.id == conversationId);
    _messagesByConversation.remove(conversationId);

    // If we deleted current conversation, switch to another or create new
    if (_currentConversationId == conversationId) {
      if (_conversations.isNotEmpty) {
        _currentConversationId = _conversations.first.id;
      } else {
        _currentConversationId = null;
      }
    }
  }

  @override
  Future<List<MessageModel>> getMessages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_currentConversationId == null) {
      return [];
    }
    return List.from(_messagesByConversation[_currentConversationId] ?? []);
  }

  @override
  Future<void> addMessage(MessageModel message) async {
    await Future.delayed(const Duration(milliseconds: 50));

    if (_currentConversationId == null) {
      await createConversation();
    }

    final messages = _messagesByConversation[_currentConversationId] ?? [];
    messages.add(message);
    _messagesByConversation[_currentConversationId!] = messages;

    // Update conversation title and message count
    final convIndex = _conversations.indexWhere(
      (c) => c.id == _currentConversationId,
    );
    if (convIndex >= 0) {
      final conv = _conversations[convIndex];
      String newTitle = conv.title;

      // Update title from first user message if still "New Chat"
      if (conv.title == 'New Chat' && message.role == MessageRole.user) {
        newTitle = Conversation.generateTitle(message.content);
      }

      _conversations[convIndex] = ConversationModel(
        id: conv.id,
        title: newTitle,
        createdAt: conv.createdAt,
        updatedAt: DateTime.now(),
        messageCount: messages.length,
      );
    }
  }

  @override
  Future<MessageModel> getAIResponse(String userMessage) async {
    // Simulate AI thinking time
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));

    final response = _mockResponses[_random.nextInt(_mockResponses.length)];

    return MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: response,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<void> clearMessages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_currentConversationId != null) {
      _messagesByConversation[_currentConversationId!] = [];

      // Update conversation message count
      final convIndex = _conversations.indexWhere(
        (c) => c.id == _currentConversationId,
      );
      if (convIndex >= 0) {
        final conv = _conversations[convIndex];
        _conversations[convIndex] = ConversationModel(
          id: conv.id,
          title: 'New Chat',
          createdAt: conv.createdAt,
          updatedAt: DateTime.now(),
          messageCount: 0,
        );
      }
    }
  }
}
