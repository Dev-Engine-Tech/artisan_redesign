import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/messages/domain/repositories/messages_repository.dart';
import 'package:artisans_circle/features/messages/presentation/bloc/conversations_bloc.dart';
import 'package:artisans_circle/features/messages/presentation/manager/chat_manager.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import 'chat_page.dart';

/// Try to get current user ID, returns null if not authenticated
int? _tryGetCurrentUserId(BuildContext context) {
  final userIdString = ChatManager().tryGetCurrentUserId(context);
  if (userIdString == null) return null;
  return int.tryParse(userIdString);
}

/// Messages list page showing all conversations
///
/// Displays a list of conversations with unread counts,
/// last message previews, and online status indicators.
class MessagesListPage extends StatelessWidget {
  const MessagesListPage({super.key});

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final repo = getIt<MessagesRepository>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface.withValues(alpha: 0.54)),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        title: Text('Messages',
            style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colorScheme.onSurface.withValues(alpha: 0.54)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface.withValues(alpha: 0.54)),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            // Wait for auth to resolve
            if (authState is AuthInitial || authState is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Check if user is authenticated
            if (authState is! AuthAuthenticated) {
              // Not authenticated at all
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 64, color: colorScheme.onSurface.withValues(alpha: 0.26)),
                    AppSpacing.spaceLG,
                    Text('Authentication Required',
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600)),
                    AppSpacing.spaceSM,
                    Text('Please sign in to view your messages',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.54))),
                    AppSpacing.spaceXXL,
                    PrimaryButton(
                      text: 'Go Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              );
            }

            // User is authenticated but ID might be missing
            final userId = authState.user.id;

            // Debug logging to see what's in the user object
            debugPrint('🔍 Messages: User ID: $userId');
            debugPrint('🔍 Messages: User phone: ${authState.user.phone}');
            debugPrint('🔍 Messages: User name: ${authState.user.fullName}');

            if (userId == null) {
              // User authenticated but profile incomplete - show error
              debugPrint('❌ Messages: User ID is null! Cannot load messages.');
              return Center(
                child: Padding(
                  padding: AppSpacing.paddingXL,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: colorScheme.error.withValues(alpha: 0.5)),
                      AppSpacing.spaceLG,
                      Text('Profile Error',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600)),
                      AppSpacing.spaceSM,
                      Text(
                        'Your user profile is missing required information (User ID). Please try logging out and logging back in.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                      AppSpacing.spaceXXL,
                      PrimaryButton(
                        text: 'Go Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
              );
            }

            final currentUserId = userId;
            return BlocProvider(
              create: (_) => ConversationsBloc(
                repository: repo,
                currentUserId: currentUserId,
              )..add(ConversationsStarted()),
              child: BlocBuilder<ConversationsBloc, ConversationsState>(
                builder: (context, state) {
                  if (state is ConversationsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ConversationsLoaded) {
                    final conversations = state.conversations;
                    if (conversations.isEmpty) {
                      return const Center(child: Text('No conversations yet'));
                    }
                    return ListView.separated(
                      padding: AppSpacing.verticalSM,
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) => const Divider(height: 8),
                      itemBuilder: (context, index) {
                        final c = conversations[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatPage(conversation: c),
                            ),
                          ),
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    const CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.softPink,
                                      child: Icon(Icons.person,
                                          color: AppColors.brownHeader),
                                    ),
                                    if (c.online)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                              color: AppColors.orange,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: colorScheme.surface,
                                                  width: 2)),
                                        ),
                                      )
                                  ],
                                ),
                                AppSpacing.spaceMD,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c.name,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _formatTime(c.lastTimestamp),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      if (c.jobTitle != null)
                                        Text(
                                          c.jobTitle!,
                                          style: const TextStyle(
                                              color: AppColors.orange,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c.isTyping
                                                  ? 'typing…'
                                                  : (c.lastMessage ?? ''),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: c.isTyping
                                                        ? AppColors.orange
                                                        : colorScheme.onSurface.withValues(alpha: 0.54),
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (c.unreadCount > 0)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                  color: AppColors.orange,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Text(
                                                '${c.unreadCount}',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                    color: colorScheme.onPrimary),
                                              ),
                                            )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (state is ConversationsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
