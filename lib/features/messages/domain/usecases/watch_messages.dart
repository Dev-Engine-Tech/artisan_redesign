import '../entities/message.dart';
import '../repositories/messages_repository.dart';

/// Use case for watching messages in a conversation
///
/// Follows the Single Responsibility Principle by handling only
/// message stream watching logic
class WatchMessages {
  final MessagesRepository _repository;

  WatchMessages(this._repository);

  /// Returns a stream of messages for a conversation
  ///
  /// Throws [ArgumentError] if conversationId is empty
  /// Returns [Stream<List<Message>>] that emits message updates
  Stream<List<Message>> call({
    required int currentUserId,
    required String conversationId,
  }) {
    // Validate input
    if (conversationId.trim().isEmpty) {
      throw ArgumentError('Conversation ID cannot be empty');
    }

    if (currentUserId <= 0) {
      throw ArgumentError('Invalid user ID: $currentUserId');
    }

    // Return message stream from repository
    return _repository.watchMessages(
      currentUserId: currentUserId,
      conversationId: conversationId,
    );
  }
}
