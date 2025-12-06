import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/utils/phone_number_filter.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/messages/domain/entities/conversation.dart'
    as domain;
import 'package:artisans_circle/features/messages/domain/entities/message.dart'
    as domain;
import 'package:artisans_circle/features/messages/domain/repositories/messages_repository.dart';
import 'package:artisans_circle/features/messages/presentation/bloc/chat_bloc.dart';
import 'package:artisans_circle/features/messages/presentation/bloc/conversations_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/messages/presentation/manager/chat_manager.dart';

/// Try to get current user ID, returns null if not authenticated
int? _tryGetCurrentUserId(BuildContext context) {
  final userIdString = ChatManager().tryGetCurrentUserId(context);
  if (userIdString == null) return null;
  return int.tryParse(userIdString);
}

/// Chat page for a single conversation
///
/// Displays messages in a conversation with support for:
/// - Text messages
/// - Image attachments (when enabled)
/// - Voice messages (when enabled)
/// - Reply to messages
/// - Typing indicators
class ChatPage extends StatefulWidget {
  final domain.Conversation conversation;
  final Job? job;

  const ChatPage({required this.conversation, super.key, this.job});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;
  domain.Message? _replyTo;
  // FlutterSoundRecorder? _recorder;
  bool _isRecording = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    // _recorder?.closeRecorder();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final atBottom = _scrollController.position.pixels >=
          (_scrollController.position.maxScrollExtent - 48);
      final show = !atBottom;
      if (show != _showScrollToBottom) {
        setState(() => _showScrollToBottom = show);
      }
    });
  }

  Widget _buildBubble(domain.Message m, int currentUserId) {
    final mine = m.isMine(currentUserId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    String t(DateTime dt) {
      final h = dt.hour.toString().padLeft(2, '0');
      final mi = dt.minute.toString().padLeft(2, '0');
      return '$h:$mi';
    }

    if (m.type == domain.MessageType.audio) {
      // voice placeholder bubble
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
                        style: TextStyle(color: mine ? colorScheme.onPrimary : colorScheme.onSurface)))),
            AppSpacing.spaceSM,
            Text('00:16',
                style: TextStyle(
                    color: mine ? colorScheme.onPrimary.withValues(alpha: 0.9) : colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
            if (mine) ...[
              AppSpacing.spaceSM,
              Icon(
                m.isSeen ? Icons.done_all : Icons.done,
                size: 16,
                color: m.isSeen ? colorScheme.onPrimary : colorScheme.onPrimary.withValues(alpha: 0.7),
              )
            ],
          ],
        ),
      );
    }

    if (m.type == domain.MessageType.image) {
      final fixedUrl = sanitizeImageUrl(m.mediaUrl);
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
                  ? (Image.network(
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
                              )))
                  : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image,
                            color: mine ? colorScheme.onPrimary : AppColors.brownHeader,
                            size: 48,
                          ),
                        ),
              ),
          ),
          AppSpacing.spaceXS,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t(m.timestamp),
                  style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurface.withValues(alpha: 0.45))),
              if (mine) ...[
                const SizedBox(width: 6),
                Icon(
                  m.isSeen ? Icons.done_all : Icons.done,
                  size: 14,
                  color: m.isSeen ? AppColors.orange : colorScheme.onSurface.withValues(alpha: 0.38),
                )
              ]
            ],
          )
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: mine ? AppColors.orange : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (m.replied != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: mine ? colorScheme.onPrimary.withValues(alpha: 0.24) : colorScheme.onSurface.withValues(alpha: 0.12),
                borderRadius: AppRadius.radiusMD,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    m.replied!.type == domain.MessageType.image
                        ? Icons.image
                        : m.replied!.type == domain.MessageType.audio
                            ? Icons.mic
                            : Icons.reply,
                    size: 16,
                    color: mine ? colorScheme.onPrimary.withValues(alpha: 0.7) : colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      m.replied!.text?.isNotEmpty == true
                          ? m.replied!.text!
                          : (m.replied!.type == domain.MessageType.image
                              ? 'Photo'
                              : m.replied!.type == domain.MessageType.audio
                                  ? 'Voice message'
                                  : ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: mine ? colorScheme.onPrimary.withValues(alpha: 0.7) : colorScheme.onSurface.withValues(alpha: 0.54),
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
                  m.text ?? '',
                  style: TextStyle(color: mine ? colorScheme.onPrimary : colorScheme.onSurface),
                ),
              ),
              if (mine) ...[
                AppSpacing.spaceSM,
                Text(t(m.timestamp),
                    style:
                        TextStyle(fontSize: 10, color: colorScheme.onPrimary.withValues(alpha: 0.7))),
                AppSpacing.spaceXS,
                Icon(m.isSeen ? Icons.done_all : Icons.done,
                    size: 16, color: colorScheme.onPrimary.withValues(alpha: 0.7))
              ]
            ],
          ),
        ],
      ),
    );
  }

  List<dynamic> _groupMessages(
      List<domain.Message> messages, int currentUserId) {
    final List<dynamic> items = [];
    int i = 0;
    while (i < messages.length) {
      final m = messages[i];
      if (m.type == domain.MessageType.image) {
        final sender = m.senderId;
        final List<domain.Message> group = [m];
        int j = i + 1;
        while (j < messages.length &&
            messages[j].type == domain.MessageType.image &&
            messages[j].senderId == sender) {
          group.add(messages[j]);
          j++;
        }
        if (group.length > 1) {
          items.add({'group': group, 'mine': sender == currentUserId});
          i = j;
          continue;
        }
      }
      items.add(m);
      i++;
    }
    return items;
  }

  void _handleSendMessage(BuildContext context) {
    String messageText = _controller.text.trim();

    // Check for phone numbers in the message
    if (PhoneNumberFilter.containsPhoneNumber(messageText)) {
      // Show warning dialog instead of sending the message
      _showPhoneNumberWarningDialog(context);
      return;
    }

    // Send the message if no phone numbers detected
    context.read<ChatBloc>().add(ChatSendText(
          messageText,
          replySource: _replyTo,
        ));
    _controller.clear();
    setState(() => _replyTo = null);
  }

  void _showPhoneNumberWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Phone Number Detected'),
          content: Text(PhoneNumberFilter.getPhoneNumberWarningMessage()),
          actions: [
            TextAppButton(
              text: 'OK',
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextAppButton(
              text: 'Remove & Continue',
              onPressed: () {
                // Remove phone numbers and update the text field
                String cleanedText =
                    PhoneNumberFilter.removePhoneNumbers(_controller.text);
                _controller.text = cleanedText;
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    // Try to get current user id, return error if not authenticated
    final currentUserId = _tryGetCurrentUserId(context);

    if (currentUserId == null) {
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
                icon: Icon(Icons.chevron_left, color: colorScheme.onSurface.withValues(alpha: 0.54)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          title: Text('Chat',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.brownHeader, fontWeight: FontWeight.w700)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.26)),
              AppSpacing.spaceLG,
              Text(
                'Authentication Required',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              AppSpacing.spaceSM,
              Text(
                'Please sign in to access chat',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.54)),
              ),
              AppSpacing.spaceXXL,
              PrimaryButton(
                text: 'Go Back',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }

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
              icon: Icon(Icons.chevron_left, color: colorScheme.onSurface.withValues(alpha: 0.54)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Row(
          children: [
            const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.softPink,
                child: Icon(Icons.person, color: AppColors.brownHeader)),
            AppSpacing.spaceSM,
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(conv.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.brownHeader,
                      fontWeight: FontWeight.w700)),
              Text(
                  conv.isTyping
                      ? 'typing…'
                      : (conv.online ? 'Online' : 'Offline'),
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.45))),
            ])
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.more_vert, color: colorScheme.onSurface.withValues(alpha: 0.54)),
              onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (_) => ChatBloc(
            repository: repo,
            currentUserId: currentUserId,
            conversationId: conv.id,
          )..add(ChatStarted()),
          child: Column(
            children: [
              // optional job/summary card
              if (widget.job != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: AppSpacing.paddingMD,
                    decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: AppRadius.radiusLG),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.job!.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(widget.job!.category,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.45))),
                          AppSpacing.spaceSM,
                          Text(widget.job!.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ]),
                  ),
                ),

              // messages area
              Expanded(
                child: Stack(
                  children: [
                    BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        if (state is ChatLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is ChatError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                AppSpacing.spaceLG,
                                const Text('Error loading messages',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                                AppSpacing.spaceSM,
                                Text(state.message,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.54)),
                                    textAlign: TextAlign.center),
                                AppSpacing.spaceLG,
                                PrimaryButton(
                                  text: 'Retry',
                                  onPressed: () =>
                                      context.read<ChatBloc>().add(ChatRetry()),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is ChatLoaded) {
                          final messages = state.messages;
                          if (messages.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.message_outlined,
                                      size: 64, color: colorScheme.onSurface.withValues(alpha: 0.26)),
                                  AppSpacing.spaceLG,
                                  Text('No messages yet',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.54))),
                                  AppSpacing.spaceSM,
                                  Text('Start the conversation!',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.38))),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            itemCount:
                                _groupMessages(messages, currentUserId).length +
                                    1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: colorScheme.surface,
                                        borderRadius: AppRadius.radiusLG),
                                    child: Text('Today',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.54))),
                                  ),
                                );
                              }
                              final items =
                                  _groupMessages(messages, currentUserId);
                              final item = items[index - 1];
                              if (item is domain.Message) {
                                final mine = item.isMine(currentUserId);
                                return GestureDetector(
                                  onLongPress: () async {
                                    // Message actions sheet
                                    final res =
                                        await showModalBottomSheet<String>(
                                      context: context,
                                      backgroundColor: colorScheme.surface,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(
                                                  AppRadius.xl))),
                                      builder: (_) {
                                        return SafeArea(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading:
                                                    const Icon(Icons.reply),
                                                title: const Text('Reply'),
                                                onTap: () => Navigator.pop(
                                                    context, 'reply'),
                                              ),
                                              ListTile(
                                                leading:
                                                    const Icon(Icons.forward),
                                                title: const Text('Forward'),
                                                onTap: () => Navigator.pop(
                                                    context, 'forward'),
                                              ),
                                              if (item.isMine(currentUserId))
                                                ListTile(
                                                  leading: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red),
                                                  title: const Text(
                                                      'Delete for me'),
                                                  onTap: () => Navigator.pop(
                                                      context, 'delete_me'),
                                                ),
                                              if (item.isMine(currentUserId))
                                                ListTile(
                                                  leading: const Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.red),
                                                  title: const Text(
                                                      'Delete for everyone'),
                                                  onTap: () => Navigator.pop(
                                                      context, 'delete_all'),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                    if (!mounted) return;
                                    switch (res) {
                                      case 'reply':
                                        setState(() => _replyTo = item);
                                        break;
                                      case 'forward':
                                        {
                                          final repo =
                                              getIt<MessagesRepository>();
                                          final chosen =
                                              await showModalBottomSheet<
                                                  List<domain.Conversation>>(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: colorScheme.surface,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            16))),
                                            builder: (ctx) {
                                              final selected = <String>{};
                                              return SafeArea(
                                                child: SizedBox(
                                                  height: MediaQuery.of(ctx)
                                                          .size
                                                          .height *
                                                      0.7,
                                                  child: BlocProvider(
                                                    create: (_) =>
                                                        ConversationsBloc(
                                                      repository: repo,
                                                      currentUserId:
                                                          currentUserId,
                                                    )..add(ConversationsStarted()),
                                                    child: StatefulBuilder(
                                                      builder:
                                                          (ctx, setSheetState) {
                                                        return Column(
                                                          children: [
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          16.0),
                                                              child: Text(
                                                                  'Forward to…',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          16)),
                                                            ),
                                                            const Divider(
                                                                height: 1),
                                                            Expanded(
                                                              child: BlocBuilder<
                                                                  ConversationsBloc,
                                                                  ConversationsState>(
                                                                builder:
                                                                    (context,
                                                                        state) {
                                                                  if (state
                                                                      is ConversationsLoaded) {
                                                                    final list =
                                                                        state
                                                                            .conversations;
                                                                    if (list
                                                                        .isEmpty) {
                                                                      return const Center(
                                                                          child:
                                                                              Text('No conversations yet'));
                                                                    }
                                                                    return ListView
                                                                        .separated(
                                                                      itemCount:
                                                                          list.length,
                                                                      separatorBuilder: (_,
                                                                              __) =>
                                                                          const Divider(
                                                                              height: 1),
                                                                      itemBuilder:
                                                                          (ctx,
                                                                              i) {
                                                                        final c =
                                                                            list[i];
                                                                        final checked =
                                                                            selected.contains(c.id);
                                                                        return CheckboxListTile(
                                                                          value:
                                                                              checked,
                                                                          onChanged:
                                                                              (v) {
                                                                            setSheetState(() {
                                                                              if (v == true) {
                                                                                selected.add(c.id);
                                                                              } else {
                                                                                selected.remove(c.id);
                                                                              }
                                                                            });
                                                                          },
                                                                          title: Text(
                                                                              c.name,
                                                                              style: const TextStyle(fontWeight: FontWeight.w600)),
                                                                          subtitle: Text(
                                                                              c.jobTitle ?? '',
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis),
                                                                        );
                                                                      },
                                                                    );
                                                                  }
                                                                  if (state
                                                                      is ConversationsError) {
                                                                    return Center(
                                                                        child: Text(
                                                                            'Error: ${state.message}'));
                                                                  }
                                                                  return const Center(
                                                                      child:
                                                                          CircularProgressIndicator());
                                                                },
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        OutlinedAppButton(
                                                                      text:
                                                                          'Cancel',
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(ctx),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          12),
                                                                  Expanded(
                                                                    child:
                                                                        PrimaryButton(
                                                                      text:
                                                                          'Forward (${selected.length})',
                                                                      onPressed: selected
                                                                              .isEmpty
                                                                          ? null
                                                                          : () {
                                                                              // Return selected conversations
                                                                              final list = (context.read<ConversationsBloc>().state as ConversationsLoaded).conversations.where((c) => selected.contains(c.id)).toList();
                                                                              Navigator.pop(ctx, list);
                                                                            },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          if (!mounted ||
                                              chosen == null ||
                                              chosen.isEmpty) {
                                            break;
                                          }
                                          try {
                                            for (final target in chosen) {
                                              if (item.type ==
                                                  domain.MessageType.text) {
                                                await repo.sendText(
                                                  currentUserId: currentUserId,
                                                  conversationId: target.id,
                                                  text: item.text ?? '',
                                                );
                                              } else if (item.type ==
                                                  domain.MessageType.image) {
                                                if ((item.mediaUrl ?? '')
                                                    .isNotEmpty) {
                                                  await repo.sendImage(
                                                    currentUserId:
                                                        currentUserId,
                                                    conversationId: target.id,
                                                    fileUrl: item.mediaUrl!,
                                                  );
                                                }
                                              } else if (item.type ==
                                                  domain.MessageType.audio) {
                                                if ((item.mediaUrl ?? '')
                                                    .isNotEmpty) {
                                                  await repo.sendAudio(
                                                    currentUserId:
                                                        currentUserId,
                                                    conversationId: target.id,
                                                    fileUrl: item.mediaUrl!,
                                                  );
                                                }
                                              }
                                            }
                                            if (!mounted) break;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Message forwarded to ${chosen.length} conversation(s)')),
                                            );
                                          } catch (e) {
                                            if (!mounted) break;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to forward: $e')),
                                            );
                                          }
                                          break;
                                        }
                                      case 'delete_me':
                                        {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title:
                                                  const Text('Delete for me?'),
                                              content: const Text(
                                                  'This will remove the message from your device.'),
                                              actions: [
                                                TextAppButton(
                                                  text: 'Cancel',
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                ),
                                                TextAppButton(
                                                  text: 'Delete',
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            context.read<ChatBloc>().add(
                                                ChatDeleteMessage(item.id,
                                                    forEveryone: false));
                                            if (!mounted) break;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    'Message deleted'),
                                                action: SnackBarAction(
                                                  label: 'Undo',
                                                  onPressed: () async {
                                                    final repo = getIt<
                                                        MessagesRepository>();
                                                    try {
                                                      if (item.type ==
                                                          domain.MessageType
                                                              .text) {
                                                        await repo.sendText(
                                                          currentUserId:
                                                              currentUserId,
                                                          conversationId:
                                                              conv.id,
                                                          text: item.text ?? '',
                                                        );
                                                      } else if (item.type ==
                                                          domain.MessageType
                                                              .image) {
                                                        if ((item.mediaUrl ??
                                                                '')
                                                            .isNotEmpty) {
                                                          await repo.sendImage(
                                                            currentUserId:
                                                                currentUserId,
                                                            conversationId:
                                                                conv.id,
                                                            fileUrl:
                                                                item.mediaUrl!,
                                                          );
                                                        }
                                                      } else if (item.type ==
                                                          domain.MessageType
                                                              .audio) {
                                                        if ((item.mediaUrl ??
                                                                '')
                                                            .isNotEmpty) {
                                                          await repo.sendAudio(
                                                            currentUserId:
                                                                currentUserId,
                                                            conversationId:
                                                                conv.id,
                                                            fileUrl:
                                                                item.mediaUrl!,
                                                          );
                                                        }
                                                      }
                                                    } catch (_) {}
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                          break;
                                        }
                                      case 'delete_all':
                                        {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text(
                                                  'Delete for everyone?'),
                                              content: const Text(
                                                  'This will permanently delete the message for all participants.'),
                                              actions: [
                                                TextAppButton(
                                                  text: 'Cancel',
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                ),
                                                TextAppButton(
                                                  text: 'Delete',
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true && mounted) {
                                            context.read<ChatBloc>().add(
                                                ChatDeleteMessage(item.id,
                                                    forEveryone: true));
                                          }
                                          break;
                                        }
                                      default:
                                    }
                                  },
                                  child: Padding(
                                    padding: AppSpacing.verticalSM,
                                    child: Row(
                                      mainAxisAlignment: mine
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                            child: _buildBubble(
                                                item, currentUserId)),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (item is Map) {
                                final List<domain.Message> group =
                                    item['group'];
                                final bool mine = item['mine'] as bool;
                                return Padding(
                                  padding: AppSpacing.verticalSM,
                                  child: Row(
                                    mainAxisAlignment: mine
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: mine
                                                ? AppColors.orange
                                                : AppColors.cardBackground,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              for (final g in group)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: SizedBox(
                                                    width: 100,
                                                    height: 100,
                                                    child: (() {
                                                      final fixed = sanitizeImageUrl(g.mediaUrl);
                                                      final valid = fixed.startsWith('http');
                                                      return valid
                                                          ? Image.network(
                                                              fixed,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (_, __, ___) => Container(
                                                                    color: colorScheme
                                                                        .surfaceContainerHighest,
                                                                    child: Icon(
                                                                        Icons.image,
                                                                        color: mine
                                                                            ? colorScheme
                                                                                .onPrimary
                                                                            : AppColors
                                                                                .brownHeader),
                                                                  ),
                                                            )
                                                          : Container(
                                                            color:
                                                                colorScheme.surfaceContainerHighest,
                                                            child: Icon(
                                                                Icons.image,
                                                                color: mine
                                                                    ? colorScheme
                                                                        .onPrimary
                                                                    : AppColors
                                                                        .brownHeader),
                                                          );
                                                    })(),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        }
                        if (state is ChatError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    if (_showScrollToBottom)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 12.0, bottom: 90),
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: AppColors.orange,
                            onPressed: () => _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                            child: Icon(Icons.arrow_downward,
                                color: colorScheme.onPrimary),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // reply preview
              if (_replyTo != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: AppRadius.radiusLG,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _replyTo!.type == domain.MessageType.image
                              ? Icons.image
                              : _replyTo!.type == domain.MessageType.audio
                                  ? Icons.mic
                                  : Icons.reply,
                          size: 18,
                          color: AppColors.brownHeader,
                        ),
                        AppSpacing.spaceSM,
                        Expanded(
                          child: Text(
                            _replyTo!.text?.isNotEmpty == true
                                ? _replyTo!.text!
                                : _replyTo!.type == domain.MessageType.image
                                    ? 'Photo'
                                    : 'Voice message',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _replyTo = null),
                        ),
                      ],
                    ),
                  ),
                ),

              // input area
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: AppSpacing.horizontalMD,
                        decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          children: [
                            Expanded(
                              child: BlocBuilder<ChatBloc, ChatState>(
                                builder: (context, state) {
                                  return TextField(
                                    controller: _controller,
                                    onChanged: (v) {
                                      context.read<ChatBloc>().add(
                                          ChatSetTyping(v.trim().isNotEmpty));
                                      // Real-time phone number detection for user feedback
                                      if (PhoneNumberFilter.containsPhoneNumber(
                                          v)) {
                                        // Visual feedback could be added here if needed
                                      }
                                      setState(() {});
                                    },
                                    decoration: const InputDecoration.collapsed(
                                        hintText: 'Write your message'),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.attach_file)),
                            IconButton(
                                onPressed: () {
                                  // TODO: Image picker functionality temporarily disabled
                                  // final picker = ImagePicker();
                                  // final img = await picker.pickImage(
                                  //     source: ImageSource.gallery,
                                  //     imageQuality: 70);
                                  // if (img != null && mounted) {
                                  //   context
                                  //       .read<ChatBloc>()
                                  //       .add(ChatSendImage(img.path, replySource: _replyTo));
                                  //   setState(() => _replyTo = null);
                                  // }
                                },
                                icon: const Icon(Icons.camera_alt_outlined)),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.spaceSM,
                    BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        final showSend = _controller.text.trim().isNotEmpty;
                        return GestureDetector(
                          onLongPressStart: (_) async {
                            if (showSend) return;
                            // Recording functionality temporarily disabled
                            // try {
                            //   _recorder ??= FlutterSoundRecorder();
                            //   if (!_recorder!.isPaused && !_recorder!.isRecording) {
                            //     await _recorder!.openRecorder();
                            //   }
                            //   _recordPath = null;
                            //   await _recorder!.startRecorder(toFile: 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a');
                            //   setState(() => _isRecording = true);
                            // } catch (_) {}
                          },
                          onLongPressEnd: (_) async {
                            if (!_isRecording) return;
                            // Recording functionality temporarily disabled
                            // try {
                            //   final path = await _recorder!.stopRecorder();
                            //   setState(() => _isRecording = false);
                            //   if (path != null && mounted) {
                            //     context.read<ChatBloc>().add(ChatSendAudio(path, replySource: _replyTo));
                            //     setState(() => _replyTo = null);
                            //   }
                            // } catch (_) {}
                            setState(() => _isRecording = false);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: _isRecording
                                    ? Colors.red
                                    : AppColors.orange,
                                borderRadius: BorderRadius.circular(30)),
                            child: IconButton(
                              icon: Icon(
                                showSend ? Icons.send : Icons.mic,
                                color: colorScheme.onPrimary,
                              ),
                              onPressed: () {
                                if (showSend) {
                                  _handleSendMessage(context);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
