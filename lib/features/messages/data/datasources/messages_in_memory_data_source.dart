import 'dart:async';

import '../../domain/entities/conversation.dart' as ent;
import '../../domain/entities/message.dart' as ent;

// Simple in-memory message store to make UI functional without backend.
class InMemoryMessagesStore {
  final Map<String, List<ent.Message>> _messagesByConversation = {};
  final Map<String, StreamController<List<ent.Message>>> _messageCtrls = {};
  final StreamController<List<ent.Conversation>> _conversationsCtrl = StreamController.broadcast();

  // conversationId -> Conversation meta
  final Map<String, ent.Conversation> _conversations = {};
  List<ent.Conversation> _lastConversations = const [];

  // Seed with sample data
  void seed({required int currentUserId}) {
    if (_conversations.isNotEmpty) return;
    for (var i = 0; i < 6; i++) {
      final conversationId = 'user_${i + 1}';
      final receiverId = 1000 + i; // fake peer IDs
      _conversations[conversationId] = ent.Conversation(
        id: conversationId,
        name: 'Client ${i + 1}',
        jobTitle: i % 2 == 0 ? 'Project Title Example' : 'Catalog Item',
        lastMessage: "Client: Yes, that's gonna work...",
        lastTimestamp: DateTime.now().subtract(Duration(minutes: 5 * i)),
        unreadCount: i % 3 == 0 ? 2 : 0,
        online: i % 2 == 0,
      );
      final list = <ent.Message>[
        ent.Message(
          id: 'm1',
          conversationId: conversationId,
          senderId: receiverId,
          receiverId: currentUserId,
          type: ent.MessageType.text,
          text: 'How are you doing',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isSeen: true,
        ),
        ent.Message(
          id: 'm2',
          conversationId: conversationId,
          senderId: currentUserId,
          receiverId: receiverId,
          type: ent.MessageType.text,
          text: 'Hello! ${_conversations[conversationId]!.name}',
          timestamp: DateTime.now().subtract(const Duration(minutes: 27)),
          isSeen: true,
        ),
        ent.Message(
          id: 'm3',
          conversationId: conversationId,
          senderId: receiverId,
          receiverId: currentUserId,
          type: ent.MessageType.text,
          text:
              'I can see on your profile that you are a professional fashion designer and i need your service',
          timestamp: DateTime.now().subtract(const Duration(minutes: 22)),
          isSeen: i % 3 == 0 ? false : true,
        ),
        ent.Message(
          id: 'm4',
          conversationId: conversationId,
          senderId: currentUserId,
          receiverId: receiverId,
          type: ent.MessageType.audio,
          mediaUrl: 'local://voice.m4a',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          isSeen: true,
        ),
      ];
      _messagesByConversation[conversationId] = list;
      _messageCtrls[conversationId] = StreamController<List<ent.Message>>.broadcast();
      _messageCtrls[conversationId]!.add(list);
    }
    _emitConversations();
  }

  Stream<List<ent.Conversation>> watchConversations() {
    // Push the last known value on next microtask so new listeners receive it.
    scheduleMicrotask(() {
      if (_lastConversations.isNotEmpty && !_conversationsCtrl.isClosed) {
        _conversationsCtrl.add(List.unmodifiable(_lastConversations));
      }
    });
    return _conversationsCtrl.stream;
  }

  Stream<List<ent.Message>> watchMessages(String conversationId) {
    // Emit the current list on new listeners to avoid empty initial screens.
    scheduleMicrotask(() {
      final c = _messageCtrls[conversationId];
      final list = _messagesByConversation[conversationId];
      if (c != null && !c.isClosed && list != null) {
        c.add(List.unmodifiable(list));
      }
    });
    return _messageCtrls[conversationId]!.stream;
  }

  int _derivePeerId(String conversationId, int currentUserId) {
    // Try to infer from existing messages
    final existing = _messagesByConversation[conversationId];
    if (existing != null && existing.isNotEmpty) {
      final sample = existing.first;
      return sample.senderId == currentUserId ? sample.receiverId : sample.senderId;
    }
    // Derive from conversationId (e.g., user_3 -> 1003)
    final num = int.tryParse(conversationId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    return 1000 + num;
  }

  void sendText({
    required int currentUserId,
    required String conversationId,
    required String text,
    ent.RepliedMessage? reply,
  }) {
    final receiverId = _derivePeerId(conversationId, currentUserId);
    final list = _messagesByConversation[conversationId] ??= [];
    final msg = ent.Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: currentUserId,
      receiverId: receiverId,
      type: ent.MessageType.text,
      text: text,
      timestamp: DateTime.now(),
      isSeen: false,
      replied: reply,
    );
    list.add(msg);
    _messagesByConversation[conversationId] = list;
    _messageCtrls[conversationId]?.add(List.unmodifiable(list));
    _updateConvFromMessage(conversationId, msg, incrementUnread: false);
  }

  void sendAudio({
    required int currentUserId,
    required String conversationId,
    required String fileUrl,
    ent.RepliedMessage? reply,
  }) {
    final receiverId = _derivePeerId(conversationId, currentUserId);
    final list = _messagesByConversation[conversationId] ??= [];
    final msg = ent.Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: currentUserId,
      receiverId: receiverId,
      type: ent.MessageType.audio,
      mediaUrl: fileUrl,
      timestamp: DateTime.now(),
      isSeen: false,
      replied: reply,
    );
    list.add(msg);
    _messageCtrls[conversationId]?.add(List.unmodifiable(list));
    _updateConvFromMessage(conversationId, msg, incrementUnread: false);
  }

  void sendImage({
    required int currentUserId,
    required String conversationId,
    required String fileUrl,
    ent.RepliedMessage? reply,
  }) {
    final receiverId = _derivePeerId(conversationId, currentUserId);
    final list = _messagesByConversation[conversationId] ??= [];
    final msg = ent.Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: currentUserId,
      receiverId: receiverId,
      type: ent.MessageType.image,
      mediaUrl: fileUrl,
      timestamp: DateTime.now(),
      isSeen: false,
      replied: reply,
    );
    list.add(msg);
    _messageCtrls[conversationId]?.add(List.unmodifiable(list));
    _updateConvFromMessage(conversationId, msg, incrementUnread: false);
  }

  void markSeen(String conversationId) {
    final list = _messagesByConversation[conversationId];
    if (list == null) return;
    bool changed = false;
    for (var i = 0; i < list.length; i++) {
      final m = list[i];
      if (!m.isSeen) {
        list[i] = m.copyWith(isSeen: true);
        changed = true;
      }
    }
    if (changed) {
      _messageCtrls[conversationId]?.add(List.unmodifiable(list));
      final c = _conversations[conversationId];
      if (c != null) {
        _conversations[conversationId] = c.copyWith(unreadCount: 0);
        _emitConversations();
      }
    }
  }

  void setTyping(String conversationId, bool typing) {
    final c = _conversations[conversationId];
    if (c == null) return;
    _conversations[conversationId] = c.copyWith(isTyping: typing);
    _emitConversations();
  }

  void _updateConvFromMessage(String conversationId, ent.Message msg,
      {bool incrementUnread = false}) {
    final c = _conversations[conversationId];
    if (c == null) return;
    final newC = c.copyWith(
      lastMessage: msg.type == ent.MessageType.text
          ? msg.text
          : msg.type == ent.MessageType.audio
              ? '🎵 Audio'
              : 'Attachment',
      lastTimestamp: msg.timestamp,
      unreadCount: incrementUnread ? (c.unreadCount + 1) : c.unreadCount,
    );
    _conversations[conversationId] = newC;
    _emitConversations();
  }

  void deleteMessage(String conversationId, String messageId) {
    final list = _messagesByConversation[conversationId];
    if (list == null) return;
    list.removeWhere((e) => e.id == messageId);
    _messageCtrls[conversationId]?.add(List.unmodifiable(list));
    // Update conversation lastMessage
    if (list.isNotEmpty) {
      _updateConvFromMessage(conversationId, list.last, incrementUnread: false);
    } else {
      final c = _conversations[conversationId];
      if (c != null) {
        _conversations[conversationId] = c.copyWith(lastMessage: '', lastTimestamp: DateTime.now());
        _emitConversations();
      }
    }
  }

  void _emitConversations() {
    final list = _conversations.values.toList()
      ..sort((a, b) => (b.lastTimestamp ?? DateTime(0)).compareTo(a.lastTimestamp ?? DateTime(0)));
    _lastConversations = List.unmodifiable(list);
    _conversationsCtrl.add(_lastConversations);
  }
}
