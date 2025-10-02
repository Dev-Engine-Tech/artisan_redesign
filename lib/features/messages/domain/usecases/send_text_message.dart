import '../entities/message.dart';
import '../repositories/messages_repository.dart';

/// Use case for sending a text message
///
/// Follows the Single Responsibility Principle by handling only
/// text message sending logic and validation
class SendTextMessage {
  final MessagesRepository _repository;

  SendTextMessage(this._repository);

  /// Sends a text message
  ///
  /// Throws [ArgumentError] if text is empty
  /// Returns [Future<void>] when message is sent successfully
  Future<void> call({
    required int currentUserId,
    required String conversationId,
    required String text,
    RepliedMessage? reply,
  }) async {
    // Validate input
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError('Message text cannot be empty');
    }

    if (trimmedText.length > 5000) {
      throw ArgumentError('Message text cannot exceed 5000 characters');
    }

    // Send message through repository
    await _repository.sendText(
      currentUserId: currentUserId,
      conversationId: conversationId,
      text: trimmedText,
      reply: reply,
    );

    // Clear typing indicator after sending
    await _repository.setTyping(
      currentUserId: currentUserId,
      conversationId: conversationId,
      typing: false,
    );
  }
}
