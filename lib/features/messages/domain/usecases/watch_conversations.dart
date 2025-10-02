import '../entities/conversation.dart';
import '../repositories/messages_repository.dart';

/// Use case for watching conversations list
///
/// Follows the Single Responsibility Principle by handling only
/// conversations stream watching logic
class WatchConversations {
  final MessagesRepository _repository;

  WatchConversations(this._repository);

  /// Returns a stream of conversations for a user
  ///
  /// Throws [ArgumentError] if currentUserId is invalid
  /// Returns [Stream<List<Conversation>>] that emits conversation updates
  Stream<List<Conversation>> call({
    required int currentUserId,
  }) {
    // Validate input
    if (currentUserId <= 0) {
      throw ArgumentError('Invalid user ID: $currentUserId');
    }

    // Return conversations stream from repository
    return _repository.watchConversations(
      currentUserId: currentUserId,
    );
  }
}
