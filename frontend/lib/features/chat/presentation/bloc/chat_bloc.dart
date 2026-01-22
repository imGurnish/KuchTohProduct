import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// Chat BLoC
///
/// Manages chat conversation state with session management.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  ChatBloc({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatInitial()) {
    on<LoadChat>(_onLoadChat);
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
    on<CreateNewConversation>(_onCreateNewConversation);
    on<SwitchConversation>(_onSwitchConversation);
    on<DeleteConversation>(_onDeleteConversation);
  }

  Future<void> _onLoadChat(LoadChat event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    // Get or create current conversation
    final convResult = await _chatRepository.getCurrentConversation();

    await convResult.fold((failure) async => emit(ChatError(failure.message)), (
      currentConv,
    ) async {
      final conversationsResult = await _chatRepository.getConversations();
      final messagesResult = await _chatRepository.getMessages();

      conversationsResult.fold((failure) => emit(ChatError(failure.message)), (
        conversations,
      ) {
        messagesResult.fold(
          (failure) => emit(ChatError(failure.message)),
          (messages) => emit(
            ChatReady(
              messages: messages,
              conversations: conversations,
              currentConversation: currentConv,
            ),
          ),
        );
      });
    });
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatReady) return;

    // Optimistic update: add user message immediately
    final userMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: event.content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    // Add loading placeholder for AI response
    final loadingMessage = Message(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    emit(
      ChatReady(
        messages: [...currentState.messages, userMessage, loadingMessage],
        conversations: currentState.conversations,
        currentConversation: currentState.currentConversation,
        isSending: true,
      ),
    );

    // Send message and get response
    final result = await _chatRepository.sendMessage(event.content);

    await result.fold(
      (failure) async {
        // Remove loading message on error
        final updatedMessages =
            currentState.messages.where((m) => !m.isLoading).toList()
              ..add(userMessage);
        emit(
          ChatReady(
            messages: updatedMessages,
            conversations: currentState.conversations,
            currentConversation: currentState.currentConversation,
            isSending: false,
          ),
        );
      },
      (aiResponse) async {
        // Reload all data to get updated state
        final conversationsResult = await _chatRepository.getConversations();
        final messagesResult = await _chatRepository.getMessages();
        final convResult = await _chatRepository.getCurrentConversation();

        messagesResult.fold((failure) => emit(ChatError(failure.message)), (
          messages,
        ) {
          conversationsResult.fold((failure) => null, (conversations) {
            convResult.fold(
              (failure) => null,
              (currentConv) => emit(
                ChatReady(
                  messages: messages,
                  conversations: conversations,
                  currentConversation: currentConv,
                  isSending: false,
                ),
              ),
            );
          });
        });
      },
    );
  }

  Future<void> _onClearChat(ClearChat event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ChatReady) return;

    final result = await _chatRepository.clearChat();

    await result.fold((failure) async => emit(ChatError(failure.message)), (
      _,
    ) async {
      final conversationsResult = await _chatRepository.getConversations();
      final convResult = await _chatRepository.getCurrentConversation();

      conversationsResult.fold((failure) => null, (conversations) {
        convResult.fold(
          (failure) => null,
          (currentConv) => emit(
            ChatReady(
              messages: [],
              conversations: conversations,
              currentConversation: currentConv,
            ),
          ),
        );
      });
    });
  }

  Future<void> _onCreateNewConversation(
    CreateNewConversation event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatReady) return;

    emit(const ChatLoading());

    final result = await _chatRepository.createConversation();

    await result.fold((failure) async => emit(ChatError(failure.message)), (
      newConv,
    ) async {
      final conversationsResult = await _chatRepository.getConversations();

      conversationsResult.fold(
        (failure) => emit(ChatError(failure.message)),
        (conversations) => emit(
          ChatReady(
            messages: [],
            conversations: conversations,
            currentConversation: newConv,
          ),
        ),
      );
    });
  }

  Future<void> _onSwitchConversation(
    SwitchConversation event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatReady) return;

    emit(const ChatLoading());

    final result = await _chatRepository.switchConversation(
      event.conversationId,
    );

    await result.fold((failure) async => emit(ChatError(failure.message)), (
      _,
    ) async {
      final messagesResult = await _chatRepository.getMessages();
      final convResult = await _chatRepository.getCurrentConversation();

      messagesResult.fold((failure) => emit(ChatError(failure.message)), (
        messages,
      ) {
        convResult.fold(
          (failure) => emit(ChatError(failure.message)),
          (currentConv) => emit(
            ChatReady(
              messages: messages,
              conversations: currentState.conversations,
              currentConversation: currentConv,
            ),
          ),
        );
      });
    });
  }

  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatReady) return;

    final result = await _chatRepository.deleteConversation(
      event.conversationId,
    );

    await result.fold((failure) async => emit(ChatError(failure.message)), (
      _,
    ) async {
      final conversationsResult = await _chatRepository.getConversations();
      final messagesResult = await _chatRepository.getMessages();
      final convResult = await _chatRepository.getCurrentConversation();

      conversationsResult.fold((failure) => emit(ChatError(failure.message)), (
        conversations,
      ) {
        messagesResult.fold((failure) => emit(ChatError(failure.message)), (
          messages,
        ) {
          convResult.fold(
            (failure) => emit(
              ChatReady(
                messages: messages,
                conversations: conversations,
                currentConversation: null,
              ),
            ),
            (currentConv) => emit(
              ChatReady(
                messages: messages,
                conversations: conversations,
                currentConversation: currentConv,
              ),
            ),
          );
        });
      });
    });
  }
}
