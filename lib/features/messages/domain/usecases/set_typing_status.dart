import '../repositories/messages_repository.dart';

/// Use case for setting typing status
///
/// Follows the Single Responsibility Principle by handling only
/// typing indicator logic
class SetTypingStatus {
  final MessagesRepository _repository;

  SetTypingStatus(this._repository);

  /// Sets the typing status for current user in a conversation
  ///
  /// Throws [ArgumentError] if conversationId is empty
  /// Returns [Future<void>] when typing status is updated
  Future<void> call({
    required int currentUserId,
    required String conversationId,
    required bool typing,
  }) async {
    // Validate input
    if (conversationId.trim().isEmpty) {
      throw ArgumentError('Conversation ID cannot be empty');
    }

    if (currentUserId <= 0) {
      throw ArgumentError('Invalid user ID: $currentUserId');
    }

    // Set typing status through repository
    await _repository.setTyping(
      currentUserId: currentUserId,
      conversationId: conversationId,
      typing: typing,
    );
  }
}
