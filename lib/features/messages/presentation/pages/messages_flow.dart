import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/messages/domain/entities/conversation.dart' as domain;
import 'package:artisans_circle/features/messages/domain/entities/message.dart' as domain;
import 'package:artisans_circle/features/messages/domain/repositories/messages_repository.dart';
import 'package:artisans_circle/features/messages/presentation/bloc/conversations_bloc.dart';
import 'package:artisans_circle/features/messages/presentation/bloc/chat_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:artisans_circle/features/messages/presentation/manager/chat_manager.dart';

/// Helper function to safely get current user ID as int with proper fallback
int _getCurrentUserId(BuildContext context) {
  final userIdString = ChatManager().getCurrentUserId(context);
  return int.tryParse(userIdString) ?? 1;
}

/// Simple messages flow containing:
/// - MessagesListPage: conversation list
/// - ChatPage: single conversation screen
///
/// These pages use the app theme/colors and are wired for navigation
/// from anywhere you call `Navigator.push(MaterialPageRoute(builder: (_) => MessagesListPage()));`
/// or `Navigator.push(MaterialPageRoute(builder: (_) => ChatPage(conversation: conv)));`

class MessagesListPage extends StatelessWidget {
  MessagesListPage({super.key});

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    // Determine current user id from Auth state, default to 1 for demo
    final currentUserId = _getCurrentUserId(context);

    final repo = getIt<MessagesRepository>();

    // List page does not use scroll-to-bottom logic.

    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration:
                BoxDecoration(color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        title: const Text('Messages',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: BlocProvider(
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.softPink,
                                  child: const Icon(Icons.person, color: AppColors.brownHeader),
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
                                          border: Border.all(color: Colors.white, width: 2)),
                                    ),
                                  )
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(c.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: Colors.black87)),
                                      ),
                                      Text(_formatTime(c.lastTimestamp),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (c.jobTitle != null)
                                    Text(c.jobTitle!,
                                        style: const TextStyle(
                                            color: AppColors.orange, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(c.isTyping ? 'typing…' : (c.lastMessage ?? ''),
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color:
                                                    c.isTyping ? AppColors.orange : Colors.black54),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      if (c.unreadCount > 0)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: AppColors.orange,
                                              borderRadius: BorderRadius.circular(12)),
                                          child: Text('${c.unreadCount}',
                                              style: const TextStyle(
                                                  color: Colors.white, fontSize: 12)),
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
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final domain.Conversation conversation;
  final Job? job;

  const ChatPage({super.key, required this.conversation, this.job});

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
  String? _recordPath;

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
      final atBottom =
          _scrollController.position.pixels >= (_scrollController.position.maxScrollExtent - 48);
      final show = !atBottom;
      if (show != _showScrollToBottom) {
        setState(() => _showScrollToBottom = show);
      }
    });
  }

  Widget _buildBubble(domain.Message m, int currentUserId) {
    final mine = m.isMine(currentUserId);
    String _t(DateTime dt) {
      final h = dt.hour.toString().padLeft(2, '0');
      final mi = dt.minute.toString().padLeft(2, '0');
      return '$h:$mi';
    }

    if (m.type == domain.MessageType.audio) {
      // voice placeholder bubble
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mine ? AppColors.orange : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow, color: mine ? Colors.white : AppColors.brownHeader),
            const SizedBox(width: 8),
            Container(
                width: 140,
                height: 28,
                color: Colors.transparent,
                child: const Center(
                    child: Text('▂ ▃ ▄ ▅ ▂ ▃ ▄', style: TextStyle(color: Colors.white)))),
            const SizedBox(width: 8),
            Text('00:16', style: TextStyle(color: mine ? Colors.white : Colors.grey, fontSize: 12)),
            if (mine) ...[
              const SizedBox(width: 8),
              Icon(
                m.isSeen ? Icons.done_all : Icons.done,
                size: 16,
                color: m.isSeen ? Colors.white : Colors.white70,
              )
            ],
          ],
        ),
      );
    }

    if (m.type == domain.MessageType.image) {
      final isRemote = (m.mediaUrl ?? '').startsWith('http');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: mine ? AppColors.orange : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SizedBox(
              width: 180,
              height: 180,
              child: isRemote
                  ? Image.network(m.mediaUrl!, fit: BoxFit.cover)
                  : Center(
                      child: Icon(
                        Icons.image,
                        color: mine ? Colors.white : AppColors.brownHeader,
                        size: 48,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_t(m.timestamp),
                  style: TextStyle(fontSize: 10, color: mine ? Colors.black45 : Colors.black45)),
              if (mine) ...[
                const SizedBox(width: 6),
                Icon(
                  m.isSeen ? Icons.done_all : Icons.done,
                  size: 14,
                  color: m.isSeen ? AppColors.orange : Colors.black38,
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
        color: mine ? AppColors.orange : AppColors.cardBackground,
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
                color: mine ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(8),
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
                    color: mine ? Colors.white70 : Colors.black45,
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
                        color: mine ? Colors.white70 : Colors.black54,
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
                  style: TextStyle(color: mine ? Colors.white : Colors.black87),
                ),
              ),
              if (mine) ...[
                const SizedBox(width: 8),
                Text(_t(m.timestamp), style: const TextStyle(fontSize: 10, color: Colors.white70)),
                const SizedBox(width: 4),
                Icon(m.isSeen ? Icons.done_all : Icons.done, size: 16, color: Colors.white70)
              ]
            ],
          ),
        ],
      ),
    );
  }

  List<dynamic> _groupMessages(List<domain.Message> messages, int currentUserId) {
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

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    // Determine current user id
    final currentUserId = _getCurrentUserId(context);

    final repo = getIt<MessagesRepository>();

    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration:
                BoxDecoration(color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.softPink,
                child: const Icon(Icons.person, color: AppColors.brownHeader)),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(conv.name,
                  style:
                      const TextStyle(color: AppColors.brownHeader, fontWeight: FontWeight.w700)),
              Text(conv.isTyping ? 'typing…' : (conv.online ? 'Online' : 'Offline'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45)),
            ])
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black54), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // optional job/summary card
            if (widget.job != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.job!.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(widget.job!.category,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45)),
                    const SizedBox(height: 8),
                    Text(widget.job!.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
                ),
              ),

            // messages area
            Expanded(
              child: BlocProvider(
                create: (_) => ChatBloc(
                  repository: repo,
                  currentUserId: currentUserId,
                  conversationId: conv.id,
                )..add(ChatStarted()),
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ChatLoaded) {
                      final messages = state.messages;
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        itemCount: _groupMessages(messages, currentUserId).length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Text('Today', style: TextStyle(color: Colors.black54)),
                              ),
                            );
                          }
                          final items = _groupMessages(messages, currentUserId);
                          final item = items[index - 1];
                          if (item is domain.Message) {
                            final mine = item.isMine(currentUserId);
                            return GestureDetector(
                              onLongPress: () async {
                                // Message actions sheet
                                final res = await showModalBottomSheet<String>(
                                  context: context,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.vertical(top: Radius.circular(16))),
                                  builder: (_) {
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.reply),
                                            title: const Text('Reply'),
                                            onTap: () => Navigator.pop(context, 'reply'),
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.forward),
                                            title: const Text('Forward'),
                                            onTap: () => Navigator.pop(context, 'forward'),
                                          ),
                                          if (item.isMine(currentUserId))
                                            ListTile(
                                              leading: const Icon(Icons.delete_outline,
                                                  color: Colors.red),
                                              title: const Text('Delete for me'),
                                              onTap: () => Navigator.pop(context, 'delete_me'),
                                            ),
                                          if (item.isMine(currentUserId))
                                            ListTile(
                                              leading: const Icon(Icons.delete_forever,
                                                  color: Colors.red),
                                              title: const Text('Delete for everyone'),
                                              onTap: () => Navigator.pop(context, 'delete_all'),
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
                                      final repo = getIt<MessagesRepository>();
                                      final chosen =
                                          await showModalBottomSheet<List<domain.Conversation>>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.white,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.vertical(top: Radius.circular(16))),
                                        builder: (ctx) {
                                          final selected = <String>{};
                                          return SafeArea(
                                            child: SizedBox(
                                              height: MediaQuery.of(ctx).size.height * 0.7,
                                              child: BlocProvider(
                                                create: (_) => ConversationsBloc(
                                                  repository: repo,
                                                  currentUserId: currentUserId,
                                                )..add(ConversationsStarted()),
                                                child: StatefulBuilder(
                                                  builder: (ctx, setSheetState) {
                                                    return Column(
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.all(16.0),
                                                          child: Text('Forward to…',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: 16)),
                                                        ),
                                                        const Divider(height: 1),
                                                        Expanded(
                                                          child: BlocBuilder<ConversationsBloc,
                                                              ConversationsState>(
                                                            builder: (context, state) {
                                                              if (state is ConversationsLoaded) {
                                                                final list = state.conversations;
                                                                if (list.isEmpty) {
                                                                  return const Center(
                                                                      child: Text(
                                                                          'No conversations yet'));
                                                                }
                                                                return ListView.separated(
                                                                  itemCount: list.length,
                                                                  separatorBuilder: (_, __) =>
                                                                      const Divider(height: 1),
                                                                  itemBuilder: (ctx, i) {
                                                                    final c = list[i];
                                                                    final checked =
                                                                        selected.contains(c.id);
                                                                    return CheckboxListTile(
                                                                      value: checked,
                                                                      onChanged: (v) {
                                                                        setSheetState(() {
                                                                          if (v == true) {
                                                                            selected.add(c.id);
                                                                          } else {
                                                                            selected.remove(c.id);
                                                                          }
                                                                        });
                                                                      },
                                                                      title: Text(c.name,
                                                                          style: const TextStyle(
                                                                              fontWeight:
                                                                                  FontWeight.w600)),
                                                                      subtitle: Text(
                                                                          c.jobTitle ?? '',
                                                                          maxLines: 1,
                                                                          overflow: TextOverflow
                                                                              .ellipsis),
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                              if (state is ConversationsError) {
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
                                                          padding: const EdgeInsets.all(16.0),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: OutlinedButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(ctx),
                                                                  child: const Text('Cancel'),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 12),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                  onPressed: selected.isEmpty
                                                                      ? null
                                                                      : () {
                                                                          // Return selected conversations
                                                                          final list = (context
                                                                                      .read<
                                                                                          ConversationsBloc>()
                                                                                      .state
                                                                                  as ConversationsLoaded)
                                                                              .conversations
                                                                              .where((c) => selected
                                                                                  .contains(c.id))
                                                                              .toList();
                                                                          Navigator.pop(ctx, list);
                                                                        },
                                                                  child: Text(
                                                                      'Forward (${selected.length})'),
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
                                      if (!mounted || chosen == null || chosen.isEmpty) break;
                                      try {
                                        for (final target in chosen) {
                                          if (item.type == domain.MessageType.text) {
                                            await repo.sendText(
                                              currentUserId: currentUserId,
                                              conversationId: target.id,
                                              text: item.text ?? '',
                                            );
                                          } else if (item.type == domain.MessageType.image) {
                                            if ((item.mediaUrl ?? '').isNotEmpty) {
                                              await repo.sendImage(
                                                currentUserId: currentUserId,
                                                conversationId: target.id,
                                                fileUrl: item.mediaUrl!,
                                              );
                                            }
                                          } else if (item.type == domain.MessageType.audio) {
                                            if ((item.mediaUrl ?? '').isNotEmpty) {
                                              await repo.sendAudio(
                                                currentUserId: currentUserId,
                                                conversationId: target.id,
                                                fileUrl: item.mediaUrl!,
                                              );
                                            }
                                          }
                                        }
                                        if (!mounted) break;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Message forwarded to ${chosen.length} conversation(s)')),
                                        );
                                      } catch (e) {
                                        if (!mounted) break;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to forward: $e')),
                                        );
                                      }
                                      break;
                                    }
                                  case 'delete_me':
                                    {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete for me?'),
                                          content: const Text(
                                              'This will remove the message from your device.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        context
                                            .read<ChatBloc>()
                                            .add(ChatDeleteMessage(item.id, forEveryone: false));
                                        if (!mounted) break;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Message deleted'),
                                            action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () async {
                                                final repo = getIt<MessagesRepository>();
                                                try {
                                                  if (item.type == domain.MessageType.text) {
                                                    await repo.sendText(
                                                      currentUserId: currentUserId,
                                                      conversationId: conv.id,
                                                      text: item.text ?? '',
                                                    );
                                                  } else if (item.type ==
                                                      domain.MessageType.image) {
                                                    if ((item.mediaUrl ?? '').isNotEmpty) {
                                                      await repo.sendImage(
                                                        currentUserId: currentUserId,
                                                        conversationId: conv.id,
                                                        fileUrl: item.mediaUrl!,
                                                      );
                                                    }
                                                  } else if (item.type ==
                                                      domain.MessageType.audio) {
                                                    if ((item.mediaUrl ?? '').isNotEmpty) {
                                                      await repo.sendAudio(
                                                        currentUserId: currentUserId,
                                                        conversationId: conv.id,
                                                        fileUrl: item.mediaUrl!,
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
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete for everyone?'),
                                          content: const Text(
                                              'This will permanently delete the message for all participants.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && mounted) {
                                        context
                                            .read<ChatBloc>()
                                            .add(ChatDeleteMessage(item.id, forEveryone: true));
                                      }
                                      break;
                                    }
                                  default:
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      mine ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    Flexible(child: _buildBubble(item, currentUserId)),
                                  ],
                                ),
                              ),
                            );
                          } else if (item is Map) {
                            final List<domain.Message> group = item['group'];
                            final bool mine = item['mine'] as bool;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    mine ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: mine ? AppColors.orange : AppColors.cardBackground,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          for (final g in group)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: SizedBox(
                                                width: 100,
                                                height: 100,
                                                child: (g.mediaUrl ?? '').startsWith('http')
                                                    ? Image.network(g.mediaUrl!, fit: BoxFit.cover)
                                                    : Container(
                                                        color: Colors.black12,
                                                        child: Icon(Icons.image,
                                                            color: mine
                                                                ? Colors.white
                                                                : AppColors.brownHeader),
                                                      ),
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
              ),
            ),

            // reply preview
            if (_replyTo != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(width: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                          color: AppColors.cardBackground, borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        children: [
                          Expanded(
                            child: BlocBuilder<ChatBloc, ChatState>(
                              builder: (context, state) {
                                return TextField(
                                  controller: _controller,
                                  onChanged: (v) {
                                    context
                                        .read<ChatBloc>()
                                        .add(ChatSetTyping(v.trim().isNotEmpty));
                                    setState(() {});
                                  },
                                  decoration: const InputDecoration.collapsed(
                                      hintText: 'Write your message'),
                                );
                              },
                            ),
                          ),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file)),
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
                  const SizedBox(width: 8),
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
                              color: _isRecording ? Colors.red : AppColors.orange,
                              borderRadius: BorderRadius.circular(30)),
                          child: IconButton(
                            icon: Icon(
                              showSend ? Icons.send : Icons.mic,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (showSend) {
                                context
                                    .read<ChatBloc>()
                                    .add(ChatSendText(_controller.text, replySource: _replyTo));
                                _controller.clear();
                                setState(() => _replyTo = null);
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
            if (_showScrollToBottom)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0, bottom: 90),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.orange,
                    onPressed: () => _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    ),
                    child: const Icon(Icons.arrow_downward, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
