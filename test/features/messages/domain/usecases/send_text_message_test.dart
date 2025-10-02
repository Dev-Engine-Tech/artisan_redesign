import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:artisans_circle/features/messages/domain/entities/message.dart';
import 'package:artisans_circle/features/messages/domain/repositories/messages_repository.dart';
import 'package:artisans_circle/features/messages/domain/usecases/send_text_message.dart';

class MockMessagesRepository extends Mock implements MessagesRepository {}

void main() {
  late SendTextMessage useCase;
  late MockMessagesRepository mockRepository;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const RepliedMessage(
      msgId: '',
      senderId: 0,
      type: MessageType.text,
    ));
  });

  setUp(() {
    mockRepository = MockMessagesRepository();
    useCase = SendTextMessage(mockRepository);
  });

  group('SendTextMessage', () {
    const tCurrentUserId = 1;
    const tConversationId = 'conv_123';
    const tText = 'Hello, World!';

    test('should send text message through repository', () async {
      // arrange
      when(() => mockRepository.sendText(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            reply: any(named: 'reply'),
          )).thenAnswer((_) async => Future.value());

      when(() => mockRepository.setTyping(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            typing: any(named: 'typing'),
          )).thenAnswer((_) async => Future.value());

      // act
      await useCase(
        currentUserId: tCurrentUserId,
        conversationId: tConversationId,
        text: tText,
      );

      // assert
      verify(() => mockRepository.sendText(
            currentUserId: tCurrentUserId,
            conversationId: tConversationId,
            text: tText,
            reply: null,
          )).called(1);

      verify(() => mockRepository.setTyping(
            currentUserId: tCurrentUserId,
            conversationId: tConversationId,
            typing: false,
          )).called(1);
    });

    test('should throw ArgumentError when text is empty', () async {
      // act & assert
      expect(
        () => useCase(
          currentUserId: tCurrentUserId,
          conversationId: tConversationId,
          text: '',
        ),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockRepository.sendText(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            reply: any(named: 'reply'),
          ));
    });

    test('should throw ArgumentError when text is only whitespace', () async {
      // act & assert
      expect(
        () => useCase(
          currentUserId: tCurrentUserId,
          conversationId: tConversationId,
          text: '   ',
        ),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockRepository.sendText(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            reply: any(named: 'reply'),
          ));
    });

    test('should throw ArgumentError when text exceeds 5000 characters',
        () async {
      // arrange
      final longText = 'a' * 5001;

      // act & assert
      expect(
        () => useCase(
          currentUserId: tCurrentUserId,
          conversationId: tConversationId,
          text: longText,
        ),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockRepository.sendText(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            reply: any(named: 'reply'),
          ));
    });

    test('should trim text before sending', () async {
      // arrange
      const textWithSpaces = '  Hello, World!  ';

      when(() => mockRepository.sendText(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            reply: any(named: 'reply'),
          )).thenAnswer((_) async => Future.value());

      when(() => mockRepository.setTyping(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            typing: any(named: 'typing'),
          )).thenAnswer((_) async => Future.value());

      // act
      await useCase(
        currentUserId: tCurrentUserId,
        conversationId: tConversationId,
        text: textWithSpaces,
      );

      // assert
      verify(() => mockRepository.sendText(
            currentUserId: tCurrentUserId,
            conversationId: tConversationId,
            text: 'Hello, World!', // trimmed
            reply: null,
          )).called(1);
    });

    test('should send message with reply when provided', () async {
      // arrange
      const tReply = RepliedMessage(
        msgId: 'msg_123',
        senderId: 2,
        type: MessageType.text,
        text: 'Original message',
      );

      when(() => mockRepository.sendText(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            reply: any(named: 'reply'),
          )).thenAnswer((_) async => Future.value());

      when(() => mockRepository.setTyping(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            typing: any(named: 'typing'),
          )).thenAnswer((_) async => Future.value());

      // act
      await useCase(
        currentUserId: tCurrentUserId,
        conversationId: tConversationId,
        text: tText,
        reply: tReply,
      );

      // assert
      verify(() => mockRepository.sendText(
            currentUserId: tCurrentUserId,
            conversationId: tConversationId,
            text: tText,
            reply: tReply,
          )).called(1);
    });

    test('should clear typing indicator after sending', () async {
      // arrange
      when(() => mockRepository.sendText(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            reply: any(named: 'reply'),
          )).thenAnswer((_) async => Future.value());

      when(() => mockRepository.setTyping(
            currentUserId: any(named: 'currentUserId'),
            conversationId: any(named: 'conversationId'),
            typing: any(named: 'typing'),
          )).thenAnswer((_) async => Future.value());

      // act
      await useCase(
        currentUserId: tCurrentUserId,
        conversationId: tConversationId,
        text: tText,
      );

      // assert
      verify(() => mockRepository.setTyping(
            currentUserId: tCurrentUserId,
            conversationId: tConversationId,
            typing: false,
          )).called(1);
    });
  });
}
