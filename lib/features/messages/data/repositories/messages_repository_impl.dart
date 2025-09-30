import 'dart:async';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messages_repository.dart';
import '../datasources/messages_in_memory_data_source.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final InMemoryMessagesStore store;

  MessagesRepositoryImpl(this.store);

  @override
  Stream<List<Conversation>> watchConversations({required int currentUserId}) {
    store.seed(currentUserId: currentUserId);
    return store.watchConversations();
  }

  @override
  Stream<List<Message>> watchMessages(
      {required int currentUserId, required String conversationId}) {
    store.seed(currentUserId: currentUserId);
    return store.watchMessages(conversationId);
  }

  @override
  Future<void> sendText({
    required int currentUserId,
    required String conversationId,
    required String text,
    RepliedMessage? reply,
  }) async {
    store.sendText(
      currentUserId: currentUserId,
      conversationId: conversationId,
      text: text,
      reply: reply,
    );
  }

  @override
  Future<void> markSeen(
      {required int currentUserId, required String conversationId}) async {
    store.markSeen(conversationId);
  }

  @override
  Future<void> setTyping(
      {required int currentUserId,
      required String conversationId,
      required bool typing}) async {
    store.setTyping(conversationId, typing);
  }

  @override
  Future<void> sendAudio({
    required int currentUserId,
    required String conversationId,
    required String fileUrl,
    RepliedMessage? reply,
  }) async {
    store.sendAudio(
      currentUserId: currentUserId,
      conversationId: conversationId,
      fileUrl: fileUrl,
      reply: reply,
    );
  }

  @override
  Future<void> sendImage({
    required int currentUserId,
    required String conversationId,
    required String fileUrl,
    RepliedMessage? reply,
  }) async {
    store.sendImage(
      currentUserId: currentUserId,
      conversationId: conversationId,
      fileUrl: fileUrl,
      reply: reply,
    );
  }

  @override
  Future<void> deleteMessage({
    required int currentUserId,
    required String conversationId,
    required String messageId,
    bool forEveryone = false,
  }) async {
    store.deleteMessage(conversationId, messageId);
  }
}
