part of 'conversations_bloc.dart';

abstract class ConversationsEvent extends Equatable {
  const ConversationsEvent();
  @override
  List<Object?> get props => [];
}

class ConversationsStarted extends ConversationsEvent {}

class ConversationsUpdated extends ConversationsEvent {
  final List<Conversation> conversations;
  const ConversationsUpdated(this.conversations);
  @override
  List<Object?> get props => [conversations];
}

class ConversationsFailed extends ConversationsEvent {
  final String message;
  const ConversationsFailed(this.message);
  @override
  List<Object?> get props => [message];
}
