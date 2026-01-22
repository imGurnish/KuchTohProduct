import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../models/message_model.dart';

/// Chat Repository Implementation
///
/// Implements ChatRepository with session management.
class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource _dataSource;

  ChatRepositoryImpl({required ChatLocalDataSource dataSource})
    : _dataSource = dataSource;

  @override
  ResultFuture<List<Conversation>> getConversations() async {
    try {
      final conversations = await _dataSource.getConversations();
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<Conversation> getCurrentConversation() async {
    try {
      final conversation = await _dataSource.getCurrentConversation();
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<Conversation> createConversation() async {
    try {
      final conversation = await _dataSource.createConversation();
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> switchConversation(String conversationId) async {
    try {
      await _dataSource.switchConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteConversation(String conversationId) async {
    try {
      await _dataSource.deleteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Message>> getMessages() async {
    try {
      final messages = await _dataSource.getMessages();
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<Message> sendMessage(String content) async {
    try {
      // Create and save user message
      final userMessage = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );
      await _dataSource.addMessage(userMessage);

      // Get AI response
      final aiResponse = await _dataSource.getAIResponse(content);
      await _dataSource.addMessage(aiResponse);

      return Right(aiResponse);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid clearChat() async {
    try {
      await _dataSource.clearMessages();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
