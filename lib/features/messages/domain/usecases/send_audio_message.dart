import '../entities/message.dart';
import '../repositories/messages_repository.dart';

/// Use case for sending an audio message
///
/// Follows the Single Responsibility Principle by handling only
/// audio message sending logic and validation
class SendAudioMessage {
  final MessagesRepository _repository;

  SendAudioMessage(this._repository);

  /// Sends an audio message
  ///
  /// Throws [ArgumentError] if fileUrl is empty
  /// Returns [Future<void>] when audio is sent successfully
  Future<void> call({
    required int currentUserId,
    required String conversationId,
    required String fileUrl,
    RepliedMessage? reply,
  }) async {
    // Validate input
    if (fileUrl.trim().isEmpty) {
      throw ArgumentError('Audio file URL cannot be empty');
    }

    // Send audio through repository
    await _repository.sendAudio(
      currentUserId: currentUserId,
      conversationId: conversationId,
      fileUrl: fileUrl,
      reply: reply,
    );
  }
}
