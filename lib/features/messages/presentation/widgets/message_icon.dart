import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/messages/presentation/pages/messages_flow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/repositories/messages_repository.dart';
import '../../domain/entities/conversation.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';

class MessageIcon extends StatelessWidget {
  final VoidCallback? onTap;

  const MessageIcon({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final repo = GetIt.I<MessagesRepository>();

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final int? currentUserId =
            (authState is AuthAuthenticated && authState.user.id != null)
                ? authState.user.id
                : null;

        Widget buildIcon(int unreadCount) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: onTap ??
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MessagesListPage(),
                          ),
                        );
                      },
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount <= 99 ? '$unreadCount' : '99+',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: unreadCount <= 99 ? 10 : 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }

        if (currentUserId == null) {
          // Not authenticated, no unread count
          return buildIcon(0);
        }

        return StreamBuilder<List<Conversation>>(
          stream: repo.watchConversations(currentUserId: currentUserId),
          builder: (context, snapshot) {
            final conversations = snapshot.data ?? const <Conversation>[];
            final totalUnread = conversations.fold<int>(
                0, (sum, c) => sum + (c.unreadCount.clamp(0, 999)));
            return buildIcon(totalUnread);
          },
        );
      },
    );
  }
}
