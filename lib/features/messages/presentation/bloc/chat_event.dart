part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {}

class ChatMessagesUpdated extends ChatEvent {
  final List<Message> messages;
  const ChatMessagesUpdated(this.messages);
  @override
  List<Object?> get props => [messages];
}

class ChatSendText extends ChatEvent {
  final String text;
  final Message? replySource;
  const ChatSendText(this.text, {this.replySource});
  @override
  List<Object?> get props => [text, replySource];
}

class ChatSendAudio extends ChatEvent {
  final String fileUrl;
  final Message? replySource;
  const ChatSendAudio(this.fileUrl, {this.replySource});
  @override
  List<Object?> get props => [fileUrl, replySource];
}

class ChatSetTyping extends ChatEvent {
  final bool typing;
  const ChatSetTyping(this.typing);
  @override
  List<Object?> get props => [typing];
}

class ChatSendImage extends ChatEvent {
  final String fileUrl;
  final Message? replySource;
  const ChatSendImage(this.fileUrl, {this.replySource});
  @override
  List<Object?> get props => [fileUrl, replySource];
}

class ChatDeleteMessage extends ChatEvent {
  final String messageId;
  final bool forEveryone;
  const ChatDeleteMessage(this.messageId, {this.forEveryone = false});
  @override
  List<Object?> get props => [messageId, forEveryone];
}

class ChatErrorOccurred extends ChatEvent {
  final String error;
  const ChatErrorOccurred(this.error);
  @override
  List<Object?> get props => [error];
}

class ChatRetry extends ChatEvent {}
