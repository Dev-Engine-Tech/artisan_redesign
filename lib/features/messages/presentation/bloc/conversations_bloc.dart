import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messages_repository.dart';

part 'conversations_event.dart';
part 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final MessagesRepository repository;
  final int currentUserId;
  StreamSubscription<List<Conversation>>? _sub;

  ConversationsBloc({required this.repository, required this.currentUserId})
      : super(ConversationsLoading()) {
    on<ConversationsStarted>((event, emit) async {
      emit(ConversationsLoading());
      await _sub?.cancel();
      try {
        _sub = repository.watchConversations(currentUserId: currentUserId).listen(
            (data) {
          add(ConversationsUpdated(data));
        }, onError: (e) {
          add(ConversationsFailed(e.toString()));
        }, cancelOnError: false);
      } catch (e) {
        emit(ConversationsError(e.toString()));
      }
    });

    on<ConversationsUpdated>((event, emit) {
      emit(ConversationsLoaded(conversations: event.conversations));
    });

    on<ConversationsFailed>((event, emit) {
      emit(ConversationsError(event.message));
    });
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
