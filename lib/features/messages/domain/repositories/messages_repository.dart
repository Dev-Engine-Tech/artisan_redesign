import 'dart:async';

import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class MessagesRepository {
  // Conversations
  Stream<List<Conversation>> watchConversations({required int currentUserId});

  // Messages for a conversation (peer-focused id)
  Stream<List<Message>> watchMessages(
      {required int currentUserId, required String conversationId});

  Future<void> sendText({
    required int currentUserId,
    required String conversationId,
    required String text,
    RepliedMessage? reply,
  });

  Future<void> sendAudio({
    required int currentUserId,
    required String conversationId,
    required String fileUrl,
    RepliedMessage? reply,
  });

  Future<void> sendImage({
    required int currentUserId,
    required String conversationId,
    required String fileUrl,
    RepliedMessage? reply,
  });

  Future<void> markSeen({
    required int currentUserId,
    required String conversationId,
  });

  Future<void> setTyping({
    required int currentUserId,
    required String conversationId,
    required bool typing,
  });

  Future<void> deleteMessage({
    required int currentUserId,
    required String conversationId,
    required String messageId,
    bool forEveryone,
  });
}
