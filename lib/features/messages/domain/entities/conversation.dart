import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id; // contact/peer id in simple model
  final String name;
  final String? avatarUrl;
  final String? jobTitle;
  final String? lastMessage;
  final DateTime? lastTimestamp;
  final int unreadCount;
  final bool online;
  final bool isTyping;

  const Conversation({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.jobTitle,
    this.lastMessage,
    this.lastTimestamp,
    this.unreadCount = 0,
    this.online = false,
    this.isTyping = false,
  });

  Conversation copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? jobTitle,
    String? lastMessage,
    DateTime? lastTimestamp,
    int? unreadCount,
    bool? online,
    bool? isTyping,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      jobTitle: jobTitle ?? this.jobTitle,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTimestamp: lastTimestamp ?? this.lastTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      online: online ?? this.online,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => [id, name, avatarUrl, jobTitle, lastMessage, lastTimestamp, unreadCount, online, isTyping];
}

