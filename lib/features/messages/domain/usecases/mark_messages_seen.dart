import '../repositories/messages_repository.dart';

/// Use case for marking messages as seen/read
///
/// Follows the Single Responsibility Principle by handling only
/// message read status updates
class MarkMessagesSeen {
  final MessagesRepository _repository;

  MarkMessagesSeen(this._repository);

  /// Marks all messages in a conversation as seen
  ///
  /// Throws [ArgumentError] if conversationId is empty
  /// Returns [Future<void>] when messages are marked as seen
  Future<void> call({
    required int currentUserId,
    required String conversationId,
  }) async {
    // Validate input
    if (conversationId.trim().isEmpty) {
      throw ArgumentError('Conversation ID cannot be empty');
    }

    if (currentUserId <= 0) {
      throw ArgumentError('Invalid user ID: $currentUserId');
    }

    // Mark messages as seen through repository
    await _repository.markSeen(
      currentUserId: currentUserId,
      conversationId: conversationId,
    );
  }
}
