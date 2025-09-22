import 'package:equatable/equatable.dart';

enum MessageType { text, image, video, audio }

class RepliedMessage extends Equatable {
  final String msgId;
  final int senderId;
  final MessageType type;
  final String? text;
  final String? mediaUrl;

  const RepliedMessage({
    required this.msgId,
    required this.senderId,
    required this.type,
    this.text,
    this.mediaUrl,
  });

  @override
  List<Object?> get props => [msgId, senderId, type, text, mediaUrl];
}

class Message extends Equatable {
  final String id;
  final String conversationId; // peer/contact id perspective
  final int senderId;
  final int receiverId;
  final MessageType type;
  final String? text;
  final String? mediaUrl;
  final DateTime timestamp;
  final bool isSeen;
  final RepliedMessage? replied;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.type,
    this.text,
    this.mediaUrl,
    required this.timestamp,
    required this.isSeen,
    this.replied,
  });

  bool isMine(int currentUserId) => senderId == currentUserId;

  Message copyWith({
    String? id,
    String? conversationId,
    int? senderId,
    int? receiverId,
    MessageType? type,
    String? text,
    String? mediaUrl,
    DateTime? timestamp,
    bool? isSeen,
    RepliedMessage? replied,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timestamp: timestamp ?? this.timestamp,
      isSeen: isSeen ?? this.isSeen,
      replied: replied ?? this.replied,
    );
  }

  @override
  List<Object?> get props => [id, conversationId, senderId, receiverId, type, text, mediaUrl, timestamp, isSeen, replied];
}
