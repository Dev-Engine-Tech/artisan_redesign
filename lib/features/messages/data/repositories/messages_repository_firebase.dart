import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'storage_uploader_io.dart' if (dart.library.html) 'storage_uploader_web.dart' as up;

import '../../domain/entities/conversation.dart' as ent;
import '../../domain/entities/message.dart' as ent;
import '../../domain/repositories/messages_repository.dart';

class MessagesRepositoryFirebase implements MessagesRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage = FirebaseStorage.instance;

  MessagesRepositoryFirebase(this.firestore);

  CollectionReference<Map<String, dynamic>> get _users => firestore.collection('users');

  @override
  Stream<List<ent.Conversation>> watchConversations({required int currentUserId}) {
    // Avoid Firestore errors if 'timeSent' mixed types exist by not ordering server-side.
    // Sort client-side by lastTimestamp desc instead.
    return _users
        .doc(currentUserId.toString())
        .collection('chats')
        .snapshots()
        .map((qs) {
          final list = qs.docs.map((d) => _conversationFromDoc(d)).toList();
          list.sort((a, b) => (b.lastTimestamp ?? DateTime(0)).compareTo(a.lastTimestamp ?? DateTime(0)));
          return list;
        });
  }

  ent.Conversation _conversationFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return ent.Conversation(
      id: d.id, // contact/peer id
      name: (m['name'] ?? '').toString(),
      avatarUrl: m['profilePic']?.toString(),
      jobTitle: m['jobTitle']?.toString(),
      lastMessage: m['lastMessage']?.toString(),
      lastTimestamp: _parseTime(m['timeSent']),
      unreadCount: (m['unreadCount'] ?? 0) is int
          ? m['unreadCount'] as int
          : int.tryParse('${m['unreadCount']}') ?? 0,
      online: (m['online'] ?? false) == true,
      isTyping: (m['isTyping'] ?? false) == true,
    );
  }

  DateTime? _parseTime(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      final i = int.tryParse(v);
      if (i != null) return DateTime.fromMillisecondsSinceEpoch(i);
    }
    return null;
  }

  @override
  Stream<List<ent.Message>> watchMessages({required int currentUserId, required String conversationId}) {
    return _users
        .doc(currentUserId.toString())
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((qs) => qs.docs.map((d) => _messageFromDoc(conversationId, d)).toList());
  }

  ent.Message _messageFromDoc(String conversationId, QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    final typeStr = (m['type'] ?? 'text') as String;
    final type = _typeFromString(typeStr);
    final senderId = int.tryParse('${m['senderId']}') ?? 0;
    final receiverId = int.tryParse('${m['receiverId']}') ?? 0;
    String? text = m['text'] as String?;
    String? mediaUrl;
    if (m['mediaInfo'] is Map<String, dynamic>) {
      mediaUrl = (m['mediaInfo'] as Map<String, dynamic>)['fileUrl'] as String?;
    }
    ent.RepliedMessage? replied;
    if (m['repliedMsg'] is Map<String, dynamic>) {
      final r = m['repliedMsg'] as Map<String, dynamic>;
      final rType = _typeFromString((r['type'] ?? 'text') as String);
      replied = ent.RepliedMessage(
        msgId: '${r['msgID'] ?? ''}',
        senderId: int.tryParse('${r['senderID'] ?? 0}') ?? 0,
        type: rType,
        text: r['text'] as String?,
        mediaUrl: (r['mediaInfo'] is Map<String, dynamic>)
            ? (r['mediaInfo']['fileUrl'] as String?)
            : null,
      );
    }
    return ent.Message(
      id: m['messageId'] as String? ?? d.id,
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      type: type,
      text: text,
      mediaUrl: mediaUrl,
      timestamp: _parseTime(m['timeSent']) ?? DateTime.now(),
      isSeen: (m['isSeen'] ?? false) == true,
      replied: replied,
    );
  }

  ent.MessageType _typeFromString(String t) {
    switch (t) {
      case 'audio':
        return ent.MessageType.audio;
      case 'image':
        return ent.MessageType.image;
      case 'video':
        return ent.MessageType.video;
      default:
        return ent.MessageType.text;
    }
  }

  Map<String, dynamic>? _replyToMap(ent.RepliedMessage? reply) {
    if (reply == null) return null;
    return {
      'type': _typeToString(reply.type),
      'senderID': reply.senderId,
      'msgID': reply.msgId,
      'text': reply.text ?? '',
      if (reply.mediaUrl != null)
        'mediaInfo': {
          'fileUrl': reply.mediaUrl,
        },
    };
  }

  String _typeToString(ent.MessageType t) {
    switch (t) {
      case ent.MessageType.audio:
        return 'audio';
      case ent.MessageType.image:
        return 'image';
      case ent.MessageType.video:
        return 'video';
      case ent.MessageType.text:
      default:
        return 'text';
    }
  }

  @override
  Future<void> sendText({
    required int currentUserId,
    required String conversationId,
    required String text,
    ent.RepliedMessage? reply,
  }) async {
    final receiverId = conversationId; // conversationId is peer id in this model
    final now = DateTime.now();
    final messageId = firestore.collection('_ids').doc().id;

    final batch = firestore.batch();

    void setMessage(String sender, String receiver) {
      final ref = _users
          .doc(sender)
          .collection('chats')
          .doc(receiver)
          .collection('messages')
          .doc(messageId);
      batch.set(ref, {
        'senderId': sender,
        'receiverId': receiver,
        'text': text,
        'type': 'text',
        'timeSent': now.millisecondsSinceEpoch,
        'messageId': messageId,
        'isSeen': false,
        if (_replyToMap(reply) != null) 'repliedMsg': _replyToMap(reply),
      });
    }

    void setContact(String owner, String peer, {required bool recipient}) {
      final ref = _users.doc(owner).collection('chats').doc(peer);
      batch.set(ref, {
        'contactId': peer,
        'lastMessage': text,
        'timeSent': now.millisecondsSinceEpoch,
        'isRecipient': recipient,
      }, SetOptions(merge: true));
    }

    setMessage(currentUserId.toString(), receiverId);
    setMessage(receiverId, currentUserId.toString());
    setContact(currentUserId.toString(), receiverId, recipient: false);
    setContact(receiverId, currentUserId.toString(), recipient: true);

    await batch.commit();
  }

  @override
  Future<void> markSeen({required int currentUserId, required String conversationId}) async {
    // Mark all un-seen incoming messages as seen for current user in this conversation
    final q = await _users
        .doc(currentUserId.toString())
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .where('isSeen', isEqualTo: false)
        .where('receiverId', isEqualTo: currentUserId.toString())
        .get();
    final batch = firestore.batch();
    for (final d in q.docs) {
      // Update current user's copy
      batch.update(d.reference, {'isSeen': true});
      // Update mirrored copy on sender's branch so they see the read receipt
      final msgId = d.data()['messageId'] as String? ?? d.id;
      final mirrorRef = _users
          .doc(conversationId)
          .collection('chats')
          .doc(currentUserId.toString())
          .collection('messages')
          .doc(msgId);
      batch.update(mirrorRef, {'isSeen': true});
    }
    await batch.commit();
    // Reset unreadCount field on chat contact (if used)
    await _users
        .doc(currentUserId.toString())
        .collection('chats')
        .doc(conversationId)
        .set({'unreadCount': 0}, SetOptions(merge: true));
  }

  @override
  Future<void> setTyping({required int currentUserId, required String conversationId, required bool typing}) async {
    // Persist typing on the RECEIVER's chat doc so they see you typing.
    await _users
        .doc(conversationId)
        .collection('chats')
        .doc(currentUserId.toString())
        .set({'isTyping': typing}, SetOptions(merge: true));
  }

  @override
  Future<void> sendAudio({
    required int currentUserId,
    required String conversationId,
    required String fileUrl,
    ent.RepliedMessage? reply,
  }) async {
    final receiverId = conversationId;
    final now = DateTime.now();
    final messageId = firestore.collection('_ids').doc().id;
    final batch = firestore.batch();

    String uploadedUrl = fileUrl;
    try {
      if (!fileUrl.startsWith('http')) {
        final remote = 'chats/$currentUserId/$receiverId/audio_${now.millisecondsSinceEpoch}.m4a';
        final res = await up.uploadFile(storage, fileUrl, remote, 'audio/m4a');
        if (res != null) uploadedUrl = res;
      }
    } catch (_) {}

    void setMessage(String sender, String receiver) {
      final ref = _users
          .doc(sender)
          .collection('chats')
          .doc(receiver)
          .collection('messages')
          .doc(messageId);
      batch.set(ref, {
        'senderId': sender,
        'receiverId': receiver,
        'text': 'audio',
        'type': 'audio',
        'timeSent': now.millisecondsSinceEpoch,
        'messageId': messageId,
        'isSeen': false,
        'mediaInfo': {'fileUrl': uploadedUrl},
        if (_replyToMap(reply) != null) 'repliedMsg': _replyToMap(reply),
      });
    }

    void setContact(String owner, String peer, {required bool recipient}) {
      final ref = _users.doc(owner).collection('chats').doc(peer);
      batch.set(ref, {
        'contactId': peer,
        'lastMessage': '🎵 Audio',
        'timeSent': now.millisecondsSinceEpoch,
        'isRecipient': recipient,
      }, SetOptions(merge: true));
    }

    setMessage(currentUserId.toString(), receiverId);
    setMessage(receiverId, currentUserId.toString());
    setContact(currentUserId.toString(), receiverId, recipient: false);
    setContact(receiverId, currentUserId.toString(), recipient: true);

    await batch.commit();
  }

  @override
  Future<void> sendImage({
    required int currentUserId,
    required String conversationId,
    required String fileUrl,
    ent.RepliedMessage? reply,
  }) async {
    final receiverId = conversationId;
    final now = DateTime.now();
    final messageId = firestore.collection('_ids').doc().id;
    final batch = firestore.batch();
    String uploadedUrl = fileUrl;
    try {
      if (!fileUrl.startsWith('http')) {
        final remote = 'chats/$currentUserId/$receiverId/image_${now.millisecondsSinceEpoch}.jpg';
        final res = await up.uploadFile(storage, fileUrl, remote, 'image/jpeg');
        if (res != null) uploadedUrl = res;
      }
    } catch (_) {}
    void setMessage(String sender, String receiver) {
      final ref = _users
          .doc(sender)
          .collection('chats')
          .doc(receiver)
          .collection('messages')
          .doc(messageId);
      batch.set(ref, {
        'senderId': sender,
        'receiverId': receiver,
        'text': '',
        'type': 'image',
        'timeSent': now.millisecondsSinceEpoch,
        'messageId': messageId,
        'isSeen': false,
        'mediaInfo': {'fileUrl': uploadedUrl},
        if (_replyToMap(reply) != null) 'repliedMsg': _replyToMap(reply),
      });
    }

    void setContact(String owner, String peer, {required bool recipient}) {
      final ref = _users.doc(owner).collection('chats').doc(peer);
      batch.set(ref, {
        'contactId': peer,
        'lastMessage': '📷 Photo',
        'timeSent': now.millisecondsSinceEpoch,
        'isRecipient': recipient,
      }, SetOptions(merge: true));
    }

    setMessage(currentUserId.toString(), receiverId);
    setMessage(receiverId, currentUserId.toString());
    setContact(currentUserId.toString(), receiverId, recipient: false);
    setContact(receiverId, currentUserId.toString(), recipient: true);
    await batch.commit();
  }

  @override
  Future<void> deleteMessage({
    required int currentUserId,
    required String conversationId,
    required String messageId,
    bool forEveryone = false,
  }) async {
    final myRef = _users
        .doc(currentUserId.toString())
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);
    if (!forEveryone) {
      await myRef.delete();
      return;
    }
    final otherRef = _users
        .doc(conversationId)
        .collection('chats')
        .doc(currentUserId.toString())
        .collection('messages')
        .doc(messageId);
    final batch = firestore.batch();
    batch.delete(myRef);
    batch.delete(otherRef);
    await batch.commit();
  }
}
