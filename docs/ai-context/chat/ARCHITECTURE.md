# Chat Architecture

## Overview

The chat system follows **Clean Architecture** principles with three distinct layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  ChatBloc   │  │ ChatScreen  │  │   Widgets           │ │
│  │  (State)    │  │  (UI)       │  │  (Bubbles, Input)   │ │
│  └──────┬──────┘  └─────────────┘  └─────────────────────┘ │
└─────────┼───────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌─────────────────────┐  ┌─────────────────────────────┐  │
│  │   ChatRepository    │  │   Message Entity            │  │
│  │   (Abstract)        │  │   Conversation Entity       │  │
│  └──────────┬──────────┘  └─────────────────────────────┘  │
└─────────────┼───────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌─────────────────────┐  ┌─────────────────────────────┐  │
│  │ ChatRepositoryImpl  │  │  ChatLocalDataSource        │  │
│  │ (Implementation)    │──│  (Mock/Local Storage)       │  │
│  └─────────────────────┘  └─────────────────────────────┘  │
│                           ┌─────────────────────────────┐  │
│                           │  AI Service (Future)        │  │
│                           │  (OpenAI/Anthropic/Local)   │  │
│                           └─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Send Message Flow

```mermaid
sequenceDiagram
    participant UI as ChatScreen
    participant Bloc as ChatBloc
    participant Repo as ChatRepository
    participant DS as LocalDataSource
    participant AI as AI Service

    UI->>Bloc: SendMessage(content)
    Bloc->>Bloc: Optimistically add user message
    Bloc->>Bloc: Add loading message placeholder
    Bloc->>Bloc: emit(ChatReady with isSending)
    
    Bloc->>Repo: sendMessage(content)
    Repo->>DS: addMessage(userMessage)
    Repo->>DS: generateAIResponse(content)
    DS->>AI: getCompletion(content)
    AI-->>DS: response text
    DS-->>Repo: Message
    Repo-->>Bloc: Right(assistantMessage)
    
    Bloc->>Bloc: Replace loading with real message
    Bloc->>Bloc: emit(ChatReady)
```

### Session Management Flow

```mermaid
flowchart TD
    A[ChatScreen] --> B[Open Drawer]
    B --> C[ConversationList]
    C --> D{User Action}
    
    D -->|New Chat| E[CreateNewConversation]
    D -->|Select Session| F[SwitchConversation]
    D -->|Delete Session| G[DeleteConversation]
    
    E --> H[Clear messages, new ID]
    F --> I[Load session messages]
    G --> J[Remove from list]
    
    H --> K[emit ChatReady]
    I --> K
    J --> K
```

## State Machine

```
                    ┌─────────────┐
                    │ ChatInitial │
                    └──────┬──────┘
                           │ LoadChat
                           ▼
                    ┌─────────────┐
                    │ ChatLoading │
                    └──────┬──────┘
                           │
                           ▼
    ┌─────────────────────────────────────────────┐
    │                ChatReady                     │
    │  ┌─────────────────────────────────────┐   │
    │  │ messages: List<Message>              │   │
    │  │ conversations: List<Conversation>    │   │
    │  │ currentConversation: Conversation?   │   │
    │  │ isSending: bool                      │   │
    │  └─────────────────────────────────────┘   │
    └─────────────────────────────────────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  ChatError  │
                    └─────────────┘
```

## Message Roles

| Role | Description | UI Position |
|------|-------------|-------------|
| `user` | Messages from the user | Right-aligned, accent color |
| `assistant` | AI responses | Left-aligned, surface color |

## Session Structure

```dart
class Conversation {
  final String id;           // Unique session ID
  final String title;        // Auto-generated from first message
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
}
```

## Dependency Injection

```dart
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
```

## UI Component Hierarchy

```
ChatScreen
├── AppBar
│   ├── Menu Button (opens drawer)
│   ├── Title + Message Count
│   └── New Chat Button
├── Drawer
│   └── ConversationList
│       ├── New Conversation Button
│       └── List of ConversationTiles
├── Body
│   ├── Empty State (when no messages)
│   │   └── Suggestion Chips
│   └── MessageList
│       └── MessageBubble (per message)
└── ChatInput
    ├── Attachment Button (placeholder)
    ├── TextField
    └── Send Button (animated)
```
