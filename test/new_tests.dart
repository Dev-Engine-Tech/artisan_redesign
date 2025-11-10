import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisans_circle/core/di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/messages/domain/entities/conversation.dart';
import 'package:artisans_circle/features/messages/presentation/pages/messages_flow.dart';
import 'package:artisans_circle/features/home/presentation/pages/home_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_invite_details_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Use the fake data sources/DI for deterministic tests
    SharedPreferences.setMockInitialValues({});
    await setupDependencies(useFake: true);
  });

  group('Unit — Job entity', () {
    test('copyWith should replace supplied fields and preserve others', () {
      final job = const Job(
        id: 'job_1',
        title: 'Original Title',
        category: 'Carpentry',
        description: 'desc',
        address: 'addr',
        minBudget: 10000,
        maxBudget: 20000,
        duration: '1 week',
        applied: false,
        thumbnailUrl: '',
      );

      final changed = job.copyWith(title: 'New Title', applied: true);

      expect(changed.id, equals('job_1'));
      expect(changed.title, equals('New Title'));
      expect(changed.category, equals('Carpentry'));
      expect(changed.applied, isTrue);
    });
  });

  group('Widget — Messages flow', () {
    testWidgets(
        'MessagesListPage displays conversations and opens ChatPage on tap',
        (WidgetTester tester) async {
      final widget = const MediaQuery(
        data: MediaQueryData(size: Size(390, 844)),
        child: MaterialApp(home: MessagesListPage()),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Messages list should be visible
      expect(find.byType(MessagesListPage), findsOneWidget);

      // There should be at least one avatar (conversation entry)
      expect(find.byType(CircleAvatar), findsWidgets);

      // Tap the first conversation entry to open ChatPage
      final firstConversation = find.byType(GestureDetector).first;
      await tester.tap(firstConversation);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // ChatPage should be pushed
      expect(find.byType(ChatPage), findsOneWidget);

      // Composer exists
      expect(find.byType(TextField), findsWidgets);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('ChatPage shows message bubbles and optional job summary',
        (WidgetTester tester) async {
      final conv = const Conversation(
        id: 'conv_test',
        name: 'Client Test',
        jobTitle: 'Test Project',
        lastMessage: 'Hello world',
        unreadCount: 0,
        avatarUrl: '',
        online: true,
      );

      final job = const Job(
        id: 'j1',
        title: 'Test Project',
        category: 'Test Cat',
        description: 'A test job description used for UI tests.',
        address: 'Test address',
        minBudget: 1000,
        maxBudget: 2000,
        duration: '2 days',
      );

      final widget = MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: MaterialApp(home: ChatPage(conversation: conv, job: job)),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // ChatPage visible and job summary is shown
      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.text('Test Project'),
          findsWidgets); // appears in header and job card

      // Bubbles should render (sample messages in ChatPage)
      expect(find.text('How are you doing'), findsOneWidget);
      expect(find.text('Hello! Lee Williamson'), findsOneWidget);

      // Composer input present
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('Widget — Home and navigation', () {
    testWidgets('HomePage shows tabs including Orders and the hero PageView',
        (WidgetTester tester) async {
      final widget = const MediaQuery(
        data: MediaQueryData(size: Size(390, 844)),
        child: MaterialApp(home: HomePage()),
      );

      await tester.pumpWidget(widget);
      // Allow timers/animations to settle briefly
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // The tabs should include Orders
      expect(find.text('Orders'), findsOneWidget);

      // Hero is a PageView (auto-scrolling banners)
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets(
        'Job Invite "Message" button opens direct ChatPage with job context',
        (WidgetTester tester) async {
      final job = const Job(
        id: 'invite_1',
        title: 'Invite Test Job',
        category: 'Test Cat',
        description: 'Invite description',
        address: 'Invite address',
        minBudget: 1000,
        maxBudget: 1500,
        duration: 'A few days',
      );

      final widget = MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: MaterialApp(home: JobInviteDetailsPage(job: job)),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Find the Message button and tap it (should open ChatPage directly)
      final messageBtn = find.widgetWithText(ElevatedButton, 'Message');
      expect(messageBtn, findsOneWidget);

      await tester.tap(messageBtn);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // ChatPage should be visible and the job title should be present (from job card)
      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.text('Invite Test Job'), findsWidgets);
    });
  });
}
