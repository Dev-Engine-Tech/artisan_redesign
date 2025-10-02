import '../entities/message.dart';
import '../repositories/messages_repository.dart';

/// Use case for sending an image message
///
/// Follows the Single Responsibility Principle by handling only
/// image message sending logic and validation
class SendImageMessage {
  final MessagesRepository _repository;

  SendImageMessage(this._repository);

  /// Sends an image message
  ///
  /// Throws [ArgumentError] if fileUrl is empty
  /// Returns [Future<void>] when image is sent successfully
  Future<void> call({
    required int currentUserId,
    required String conversationId,
    required String fileUrl,
    RepliedMessage? reply,
  }) async {
    // Validate input
    if (fileUrl.trim().isEmpty) {
      throw ArgumentError('Image file URL cannot be empty');
    }

    // Send image through repository
    await _repository.sendImage(
      currentUserId: currentUserId,
      conversationId: conversationId,
      fileUrl: fileUrl,
      reply: reply,
    );
  }
}
