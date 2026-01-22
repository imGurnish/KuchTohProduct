part of 'chat_bloc.dart';

/// Chat BLoC States
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Loading chat history
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Chat ready with messages and conversations
class ChatReady extends ChatState {
  final List<Message> messages;
  final List<Conversation> conversations;
  final Conversation? currentConversation;
  final bool isSending;

  const ChatReady({
    required this.messages,
    required this.conversations,
    this.currentConversation,
    this.isSending = false,
  });

  @override
  List<Object?> get props => [
    messages,
    conversations,
    currentConversation,
    isSending,
  ];

  ChatReady copyWith({
    List<Message>? messages,
    List<Conversation>? conversations,
    Conversation? currentConversation,
    bool? isSending,
  }) {
    return ChatReady(
      messages: messages ?? this.messages,
      conversations: conversations ?? this.conversations,
      currentConversation: currentConversation ?? this.currentConversation,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// Error state
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
