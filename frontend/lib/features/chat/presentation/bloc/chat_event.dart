part of 'chat_bloc.dart';

/// Chat BLoC Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Load chat and conversations
class LoadChat extends ChatEvent {
  const LoadChat();
}

/// Send a message
class SendMessage extends ChatEvent {
  final String content;

  const SendMessage(this.content);

  @override
  List<Object?> get props => [content];
}

/// Clear all chat messages in current conversation
class ClearChat extends ChatEvent {
  const ClearChat();
}

/// Create a new conversation
class CreateNewConversation extends ChatEvent {
  const CreateNewConversation();
}

/// Switch to a different conversation
class SwitchConversation extends ChatEvent {
  final String conversationId;

  const SwitchConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Delete a conversation
class DeleteConversation extends ChatEvent {
  final String conversationId;

  const DeleteConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}
