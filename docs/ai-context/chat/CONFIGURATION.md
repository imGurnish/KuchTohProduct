# Chat Configuration

## Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  fpdart: ^1.1.0
```

## Dependency Injection

In `lib/core/di/injection_container.dart`:

```dart
void initChatFeature() {
  // Data Sources
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(dataSource: sl<ChatLocalDataSource>()),
  );

  // BLoC
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(chatRepository: sl<ChatRepository>()),
  );
}
```

## Integrating Real AI

### Option 1: OpenAI

```dart
class OpenAIService {
  final String apiKey;
  
  Future<String> getCompletion(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );
    
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}
```

### Option 2: Anthropic Claude

```dart
class ClaudeService {
  final String apiKey;
  
  Future<String> getCompletion(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'claude-3-sonnet-20240229',
        'max_tokens': 1024,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );
    
    final data = jsonDecode(response.body);
    return data['content'][0]['text'];
  }
}
```

### Option 3: Local LLM (Ollama)

```dart
class OllamaService {
  final String baseUrl;  // e.g., 'http://localhost:11434'
  
  Future<String> getCompletion(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'llama2',
        'prompt': prompt,
        'stream': false,
      }),
    );
    
    final data = jsonDecode(response.body);
    return data['response'];
  }
}
```

## Replacing Mock with Real AI

In `chat_local_data_source.dart`:

```dart
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final AIService _aiService;  // Inject your AI service

  ChatLocalDataSourceImpl({required AIService aiService})
      : _aiService = aiService;

  @override
  Future<MessageModel> generateAIResponse(String userMessage) async {
    // Replace mock with real AI call
    final response = await _aiService.getCompletion(userMessage);
    
    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      role: MessageRole.assistant,
      createdAt: DateTime.now(),
    );
  }
}
```

## Environment Variables

For API keys, use environment variables:

```dart
// In main.dart or config
final openAIKey = const String.fromEnvironment('OPENAI_API_KEY');
final claudeKey = const String.fromEnvironment('CLAUDE_API_KEY');
```

Run with:
```bash
flutter run --dart-define=OPENAI_API_KEY=sk-xxx
```

## Message History Context

For better AI responses, include conversation history:

```dart
Future<String> getCompletionWithHistory(
  String newMessage,
  List<Message> history,
) async {
  final messages = [
    // System prompt
    {'role': 'system', 'content': 'You are a helpful assistant.'},
    // Previous messages
    ...history.map((m) => {
      'role': m.role == MessageRole.user ? 'user' : 'assistant',
      'content': m.content,
    }),
    // New message
    {'role': 'user', 'content': newMessage},
  ];
  
  // Send to API...
}
```

## Streaming Responses

For real-time token streaming:

```dart
Stream<String> getCompletionStream(String prompt) async* {
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {...},
    body: jsonEncode({
      'model': 'gpt-4',
      'messages': [{'role': 'user', 'content': prompt}],
      'stream': true,
    }),
  );

  // Parse SSE stream
  await for (final chunk in response.body.transform(utf8.decoder)) {
    // Extract content delta
    yield parsedContent;
  }
}
```

## UI Customization

### Message Colors

```dart
// In message_bubble.dart
Color get userBubbleColor => isDark 
    ? AppColors.darkAccent 
    : AppColors.lightPrimary;

Color get assistantBubbleColor => isDark 
    ? AppColors.darkSurface 
    : AppColors.lightSurface;
```

### Loading Animation

```dart
// Typing indicator
Widget _buildLoadingIndicator() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (i) =>
      AnimatedContainer(
        duration: Duration(milliseconds: 300 + (i * 100)),
        // Bouncing dots animation
      ),
    ),
  );
}
```
