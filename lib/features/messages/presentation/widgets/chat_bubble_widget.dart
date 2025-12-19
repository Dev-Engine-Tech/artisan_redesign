import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/core/theme.dart';
import '../../domain/entities/message.dart' as domain;

/// Chat message bubble widget
///
/// Supports three message types:
/// - Text messages with optional reply
/// - Image messages
/// - Audio messages (voice notes)
class ChatBubbleWidget extends StatelessWidget {
  final domain.Message message;
  final int currentUserId;

  const ChatBubbleWidget({
    required this.message,
    required this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine(currentUserId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Audio message bubble
    if (message.type == domain.MessageType.audio) {
      return _buildAudioBubble(context, mine, colorScheme);
    }

    // Image message bubble
    if (message.type == domain.MessageType.image) {
      return _buildImageBubble(context, mine, colorScheme);
    }

    // Text message bubble
    return _buildTextBubble(context, mine, colorScheme);
  }

  Widget _buildAudioBubble(
    BuildContext context,
    bool mine,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: mine ? AppColors.orange : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow,
              color: mine ? colorScheme.onPrimary : AppColors.brownHeader),
          AppSpacing.spaceSM,
          Container(
            width: 140,
            height: 28,
            color: Colors.transparent,
            child: Center(
              child: Text('▂ ▃ ▄ ▅ ▂ ▃ ▄',
                  style: TextStyle(
                      color: mine
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface)),
            ),
          ),
          AppSpacing.spaceSM,
          Text('00:16',
              style: TextStyle(
                  color: mine
                      ? colorScheme.onPrimary.withValues(alpha: 0.9)
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12)),
          if (mine) ...[
            AppSpacing.spaceSM,
            Icon(
              message.isSeen ? Icons.done_all : Icons.done,
              size: 16,
              color: message.isSeen
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimary.withValues(alpha: 0.7),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildImageBubble(
    BuildContext context,
    bool mine,
    ColorScheme colorScheme,
  ) {
    final fixedUrl = sanitizeImageUrl(message.mediaUrl);
    final isRemote = fixedUrl.startsWith('http');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: mine ? AppColors.orange : colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: SizedBox(
            width: 180,
            height: 180,
            child: isRemote
                ? Image.network(
                    fixedUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image,
                        color: mine
                            ? colorScheme.onPrimary
                            : AppColors.brownHeader,
                        size: 48,
                      ),
                    ),
                  )
                : Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image,
                      color:
                          mine ? colorScheme.onPrimary : AppColors.brownHeader,
                      size: 48,
                    ),
                  ),
          ),
        ),
        AppSpacing.spaceXS,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_formatTime(message.timestamp),
                style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurface.withValues(alpha: 0.45))),
            if (mine) ...[
              const SizedBox(width: 6),
              Icon(
                message.isSeen ? Icons.done_all : Icons.done,
                size: 14,
                color: message.isSeen
                    ? AppColors.orange
                    : colorScheme.onSurface.withValues(alpha: 0.38),
              )
            ]
          ],
        )
      ],
    );
  }

  Widget _buildTextBubble(
    BuildContext context,
    bool mine,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: mine ? AppColors.orange : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.replied != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: mine
                    ? colorScheme.onPrimary.withValues(alpha: 0.24)
                    : colorScheme.onSurface.withValues(alpha: 0.12),
                borderRadius: AppRadius.radiusMD,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    message.replied!.type == domain.MessageType.image
                        ? Icons.image
                        : message.replied!.type == domain.MessageType.audio
                            ? Icons.mic
                            : Icons.reply,
                    size: 16,
                    color: mine
                        ? colorScheme.onPrimary.withValues(alpha: 0.7)
                        : colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      message.replied!.text?.isNotEmpty == true
                          ? message.replied!.text!
                          : (message.replied!.type == domain.MessageType.image
                              ? 'Photo'
                              : message.replied!.type == domain.MessageType.audio
                                  ? 'Voice message'
                                  : ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: mine
                            ? colorScheme.onPrimary.withValues(alpha: 0.7)
                            : colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  message.text ?? '',
                  style: TextStyle(
                      color: mine
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface),
                ),
              ),
              if (mine) ...[
                AppSpacing.spaceSM,
                Text(_formatTime(message.timestamp),
                    style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onPrimary.withValues(alpha: 0.7))),
                AppSpacing.spaceXS,
                Icon(message.isSeen ? Icons.done_all : Icons.done,
                    size: 16,
                    color: colorScheme.onPrimary.withValues(alpha: 0.7))
              ]
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$h:$mi';
  }
}
