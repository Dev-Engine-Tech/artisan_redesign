import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import 'package:artisans_circle/features/messages/domain/entities/conversation.dart';
import 'package:artisans_circle/features/messages/presentation/pages/messages_flow.dart';
import 'package:artisans_circle/features/messages/presentation/bloc/chat_bloc.dart';
import 'package:artisans_circle/features/messages/domain/repositories/messages_repository.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/core/di.dart';

/// Global chat manager that handles chat navigation and state
/// Similar to the ProjectChatCtr in the working artisan app
class ChatManager {
  static final ChatManager _instance = ChatManager._internal();
  factory ChatManager() => _instance;
  ChatManager._internal();

  // Current chat context
  Conversation? _currentConversation;
  Job? _currentJob;

  Conversation? get currentConversation => _currentConversation;
  Job? get currentJob => _currentJob;

  /// Safely get current user ID, similar to working app's senderUserId
  String getCurrentUserId(BuildContext context) {
    try {
      final authBloc = context.read<AuthBloc>();
      final state = authBloc.state;
      if (state is AuthAuthenticated && state.user.id != null) {
        return state.user.id.toString(); // Convert to string like working app
      }
    } catch (e) {
      // AuthBloc not available in context, use default
    }
    return '1'; // Default user ID as string
  }

  /// Navigate to chat screen with proper context, similar to goToChatScreen
  void goToChatScreen({
    required BuildContext context,
    required Conversation conversation,
    Job? job,
  }) {
    // Store chat context globally like working app
    _currentConversation = conversation;
    _currentJob = job;

    // Get current user ID and messages repository
    final currentUserId = int.tryParse(getCurrentUserId(context)) ?? 1;
    final messagesRepository = getIt<MessagesRepository>();

    // Navigate to chat; ChatPage will provide its own ChatBloc
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(conversation: conversation, job: job),
      ),
    );
  }

  /// Create conversation for job chat (similar to working app pattern)
  Conversation createJobConversation({
    required Job job,
    String? clientName,
  }) {
    return Conversation(
      id: 'job_${job.id}',
      name: clientName ?? 'Client',
      jobTitle: job.title,
      lastMessage: '',
      lastTimestamp: DateTime.now(),
      unreadCount: 0,
      online: false,
    );
  }

  /// Create conversation for client contact
  Conversation createClientConversation({
    required String clientId,
    required String clientName,
    required String projectTitle,
  }) {
    return Conversation(
      id: 'client_$clientId',
      name: clientName,
      jobTitle: projectTitle,
      lastMessage: '',
      lastTimestamp: DateTime.now(),
      unreadCount: 0,
      online: false,
    );
  }

  /// Clear chat context when leaving chat
  void clearChatContext() {
    _currentConversation = null;
    _currentJob = null;
  }
}
