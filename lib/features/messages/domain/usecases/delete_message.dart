import '../repositories/messages_repository.dart';

/// Use case for deleting a message
///
/// Follows the Single Responsibility Principle by handling only
/// message deletion logic
class DeleteMessage {
  final MessagesRepository _repository;

  DeleteMessage(this._repository);

  /// Deletes a message
  ///
  /// [forEveryone] - if true, deletes for all participants; if false, only for current user
  /// Throws [ArgumentError] if messageId is empty
  /// Returns [Future<void>] when message is deleted successfully
  Future<void> call({
    required int currentUserId,
    required String conversationId,
    required String messageId,
    bool forEveryone = false,
  }) async {
    // Validate input
    if (messageId.trim().isEmpty) {
      throw ArgumentError('Message ID cannot be empty');
    }

    if (conversationId.trim().isEmpty) {
      throw ArgumentError('Conversation ID cannot be empty');
    }

    // Delete message through repository
    await _repository.deleteMessage(
      currentUserId: currentUserId,
      conversationId: conversationId,
      messageId: messageId,
      forEveryone: forEveryone,
    );
  }
}
