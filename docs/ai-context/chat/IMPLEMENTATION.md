# Chat Implementation Guide

## Entities

### Message

```dart
enum MessageRole { user, assistant }

class Message extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime createdAt;
  final bool isLoading;  // For typing indicator

  String get formattedTime {
    final now = DateTime.now();
    if (createdAt.day == now.day) {
      return DateFormat('h:mm a').format(createdAt);
    }
    return DateFormat('MMM d, h:mm a').format(createdAt);
  }
}
```

### Conversation

```dart
class Conversation extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;

  String get preview {
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(updatedAt);
  }
}
```

## ChatBloc Events

| Event | Description |
|-------|-------------|
| `LoadChat` | Initial load of current conversation |
| `SendMessage(content)` | Send user message and get AI response |
| `CreateNewConversation` | Start fresh chat session |
| `SwitchConversation(id)` | Change to different session |
| `DeleteConversation(id)` | Remove session |

## ChatBloc States

```dart
class ChatReady extends ChatState {
  final List<Message> messages;
  final List<Conversation> conversations;
  final Conversation? currentConversation;
  final bool isSending;
}
```

## ChatBloc Implementation

```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  Future<void> _onSendMessage(SendMessage event, emit) async {
    final currentState = state;
    if (currentState is! ChatReady) return;

    // 1. Add user message optimistically
    final userMessage = Message(
      content: event.content,
      role: MessageRole.user,
    );
    
    // 2. Add loading placeholder for AI
    final loadingMessage = Message(
      content: '',
      role: MessageRole.assistant,
      isLoading: true,
    );

    emit(currentState.copyWith(
      messages: [...currentState.messages, userMessage, loadingMessage],
      isSending: true,
    ));

    // 3. Get AI response
    final result = await _chatRepository.sendMessage(event.content);
    
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (aiMessage) {
        // Replace loading with actual response
        final updatedMessages = [...currentState.messages, userMessage, aiMessage];
        emit(currentState.copyWith(
          messages: updatedMessages,
          isSending: false,
        ));
      },
    );
  }
}
```

## ChatLocalDataSource

### Mock AI Responses

```dart
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Map<String, List<MessageModel>> _messagesBySession = {};
  String _currentSessionId = '';

  Future<MessageModel> generateAIResponse(String userMessage) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate contextual mock response
    final response = _getMockResponse(userMessage);
    
    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      role: MessageRole.assistant,
      createdAt: DateTime.now(),
    );
  }

  String _getMockResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi')) {
      return "Hello! I'm your AI assistant. How can I help you today?";
    }
    if (lower.contains('help')) {
      return "I can help you with organizing files, answering questions, and more!";
    }
    return "That's interesting! Tell me more about what you're looking for.";
  }
}
```

### Session Management

```dart
Future<Conversation> createConversation() async {
  final id = DateTime.now().millisecondsSinceEpoch.toString();
  final conversation = ConversationModel(
    id: id,
    title: 'New Conversation',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    messageCount: 0,
  );
  _conversations.add(conversation);
  _currentSessionId = id;
  _messagesBySession[id] = [];
  return conversation;
}

Future<void> switchConversation(String id) async {
  _currentSessionId = id;
}
```

## UI Widgets

### MessageBubble

```dart
class MessageBubble extends StatelessWidget {
  final Message message;

  Widget build(context) {
    final isUser = message.role == MessageRole.user;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? accentColor : surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: message.isLoading
            ? _buildLoadingIndicator()
            : Text(message.content),
      ),
    );
  }
}
```

### ChatInput

```dart
class ChatInput extends StatelessWidget {
  final Function(String) onSend;
  final bool isEnabled;

  Widget build(context) {
    return Row(
      children: [
        IconButton(icon: Icon(Icons.attach_file)),  // Placeholder
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Type a message...'),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: isEnabled ? () => onSend(_controller.text) : null,
        ),
      ],
    );
  }
}
```

### ConversationList (Drawer)

```dart
class ConversationList extends StatelessWidget {
  final List<Conversation> conversations;
  final Conversation? currentConversation;
  final Function() onNewConversation;
  final Function(String) onSelectConversation;
  final Function(String) onDeleteConversation;

  Widget build(context) {
    return Drawer(
      child: Column(
        children: [
          // Header with New Chat button
          _buildHeader(),
          // List of sessions
          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (_, index) => _buildTile(conversations[index]),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Empty State Suggestions

```dart
final _suggestions = [
  'What can you help me with?',
  'How do I organize my files?',
  'Tell me about yourself',
];

Widget _buildEmptyState() {
  return Column(
    children: [
      Icon(Icons.chat_bubble_outline),
      Text('Start a conversation'),
      Wrap(
        children: _suggestions.map((s) =>
          ActionChip(
            label: Text(s),
            onPressed: () => _sendMessage(s),
          ),
        ).toList(),
      ),
    ],
  );
}
```
