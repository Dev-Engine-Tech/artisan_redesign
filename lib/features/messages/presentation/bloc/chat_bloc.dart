import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/message.dart';
import '../../domain/repositories/messages_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final MessagesRepository repository;
  final int currentUserId;
  final String conversationId;
  // Optional when repository can infer receiver from conversation
  final int? peerUserId;

  StreamSubscription<List<Message>>? _sub;

  ChatBloc({
    required this.repository,
    required this.currentUserId,
    required this.conversationId,
    this.peerUserId,
  }) : super(ChatLoading()) {
    on<ChatStarted>((event, emit) async {
      emit(ChatLoading());
      await _sub?.cancel();
      _sub = repository
          .watchMessages(
              currentUserId: currentUserId, conversationId: conversationId)
          .listen((data) {
        add(ChatMessagesUpdated(data));
      });
      // mark as seen when opening chat
      unawaited(repository.markSeen(
          currentUserId: currentUserId, conversationId: conversationId));
    });

    on<ChatMessagesUpdated>((event, emit) {
      emit(ChatLoaded(messages: event.messages));
    });

    on<ChatSendText>((event, emit) async {
      if (event.text.trim().isEmpty) return;
      RepliedMessage? reply;
      if (event.replySource != null) {
        final r = event.replySource!;
        reply = RepliedMessage(
          msgId: r.id,
          senderId: r.senderId,
          type: r.type,
          text: r.text,
          mediaUrl: r.mediaUrl,
        );
      }
      await repository.sendText(
        currentUserId: currentUserId,
        conversationId: conversationId,
        text: event.text.trim(),
        reply: reply,
      );
      await repository.setTyping(
        currentUserId: currentUserId,
        conversationId: conversationId,
        typing: false,
      );
    });

    on<ChatSetTyping>((event, emit) async {
      await repository.setTyping(
        currentUserId: currentUserId,
        conversationId: conversationId,
        typing: event.typing,
      );
    });

    on<ChatSendAudio>((event, emit) async {
      RepliedMessage? reply;
      if (event.replySource != null) {
        final r = event.replySource!;
        reply = RepliedMessage(
          msgId: r.id,
          senderId: r.senderId,
          type: r.type,
          text: r.text,
          mediaUrl: r.mediaUrl,
        );
      }
      await repository.sendAudio(
        currentUserId: currentUserId,
        conversationId: conversationId,
        fileUrl: event.fileUrl,
        reply: reply,
      );
    });

    on<ChatSendImage>((event, emit) async {
      RepliedMessage? reply;
      if (event.replySource != null) {
        final r = event.replySource!;
        reply = RepliedMessage(
          msgId: r.id,
          senderId: r.senderId,
          type: r.type,
          text: r.text,
          mediaUrl: r.mediaUrl,
        );
      }
      await repository.sendImage(
        currentUserId: currentUserId,
        conversationId: conversationId,
        fileUrl: event.fileUrl,
        reply: reply,
      );
    });

    on<ChatDeleteMessage>((event, emit) async {
      await repository.deleteMessage(
        currentUserId: currentUserId,
        conversationId: conversationId,
        messageId: event.messageId,
        forEveryone: event.forEveryone,
      );
    });
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
