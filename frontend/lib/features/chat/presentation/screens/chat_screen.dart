import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/message_list.dart';
import '../widgets/chat_input.dart';
import '../widgets/conversation_list.dart';

/// Chat Screen
///
/// Main chat interface with session management drawer.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatBloc>()..add(const LoadChat()),
      child: _ChatScreenContent(scaffoldKey: _scaffoldKey),
    );
  }
}

class _ChatScreenContent extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _ChatScreenContent({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      drawer: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatReady) {
            return Drawer(
              child: ConversationList(
                conversations: state.conversations,
                currentConversation: state.currentConversation,
                onSelect: (id) {
                  context.read<ChatBloc>().add(SwitchConversation(id));
                },
                onDelete: (id) {
                  context.read<ChatBloc>().add(DeleteConversation(id));
                },
                onNewChat: () {
                  context.read<ChatBloc>().add(const CreateNewConversation());
                  Navigator.pop(context);
                },
                onClose: () => Navigator.pop(context),
              ),
            );
          }
          return const SizedBox();
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Messages or Empty State
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return _buildLoadingState(isDark);
                  }
                  if (state is ChatError) {
                    return _buildErrorState(context, state.message, isDark);
                  }
                  if (state is ChatReady) {
                    if (state.messages.isEmpty) {
                      return _buildEmptyState(isDark);
                    }
                    return MessageList(messages: state.messages);
                  }
                  return const SizedBox();
                },
              ),
            ),
            // Input
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final isSending = state is ChatReady && state.isSending;
                return ChatInput(
                  isSending: isSending,
                  onSend: (content) {
                    context.read<ChatBloc>().add(SendMessage(content));
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          // Menu button to open drawer
          IconButton(
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
            icon: Icon(
              Icons.menu_rounded,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            tooltip: 'Chat history',
          ),
          const SizedBox(width: 4),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.purple20
                  : AppColors.lightPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              size: 18,
              color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                String title = 'Chat';
                String subtitle = 'Ask about your files';

                if (state is ChatReady && state.currentConversation != null) {
                  title = state.currentConversation!.title;
                  subtitle = '${state.messages.length} messages';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // New chat button
          IconButton(
            onPressed: () {
              context.read<ChatBloc>().add(const CreateNewConversation());
            },
            icon: Icon(
              Icons.add_comment_rounded,
              color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
            ),
            tooltip: 'New chat',
          ),
          // Clear button
          IconButton(
            onPressed: () => _showClearDialog(context, isDark),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            tooltip: 'Clear chat',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  void _showClearDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        title: Text(
          'Clear Chat',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all messages in this conversation?',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatBloc>().add(const ClearChat());
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ChatBloc>().add(const LoadChat());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.purple20
                    : AppColors.lightPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 50,
                color: isDark ? AppColors.darkAccent : AppColors.lightPrimary,
              ),
            ).animate().fadeIn().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Mindspace',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 12),
            Text(
              'Ask me anything about your files.\nI can help you search, summarize, and discover insights.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  text: '📸 Find my vacation photos',
                  isDark: isDark,
                ),
                _SuggestionChip(
                  text: '📝 Summarize meeting notes',
                  isDark: isDark,
                ),
                _SuggestionChip(text: '🔍 Search for ML docs', isDark: isDark),
              ],
            ).animate(delay: 300.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SuggestionChip({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}
