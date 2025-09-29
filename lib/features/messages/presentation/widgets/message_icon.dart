import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/messages/presentation/pages/messages_flow.dart';

class MessageIcon extends StatelessWidget {
  final VoidCallback? onTap;

  const MessageIcon({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Simplified version to avoid performance issues with ConversationsBloc
    // In a real app, you'd want to get this from a global state or cache
    const int unreadCount = 3; // Mock unread count for now
    
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
}