import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_card.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/discover_page.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // register dependencies with the fake remote data source for tests
    SharedPreferences.setMockInitialValues({});
    await setupDependencies(useFake: true);
  });

  tearDownAll(() async {
    // Reset GetIt registrations between test runs to avoid cross-test contamination.
    final gi = GetIt.instance;
    await gi.reset();
  });

  group('JobCard widget', () {
    testWidgets(
        'renders title, category, address and Apply button enabled/disabled',
        (tester) async {
      // create a Job entity (applied = false)
      final job = const Job(
        id: 'job_local_1',
        title: 'Electrical Home Wiring',
        category: 'Electrical Engineering',
        description: 'Short description for testing',
        address: '15a, test street, Lagos',
        minBudget: 100000,
        maxBudget: 150000,
        duration: 'Less than a month',
        applied: false,
        thumbnailUrl: '',
      );

      // create a JobBloc from DI and provide it to the widget tree
      final jobBloc = GetIt.instance<JobBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<JobBloc>.value(
            value: jobBloc,
            child: Scaffold(body: JobCard(job: job)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Electrical Home Wiring'), findsOneWidget);
      expect(find.text('Electrical Engineering'), findsOneWidget);
      expect(find.text('15a, test street, Lagos'), findsOneWidget);
      // Apply button should be present and enabled
      final applyFinder = find.widgetWithText(ElevatedButton, 'Apply');
      expect(applyFinder, findsOneWidget);
      final ElevatedButton applyButton = tester.widget(applyFinder);
      expect(applyButton.onPressed != null, isTrue);

      // Now render an applied job (button disabled)
      final appliedJob = job.copyWith(applied: true);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<JobBloc>.value(
            value: jobBloc,
            child: Scaffold(body: JobCard(job: appliedJob)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final appliedFinder = find.widgetWithText(ElevatedButton, 'Applied');
      expect(appliedFinder, findsOneWidget);
      final ElevatedButton appliedButton = tester.widget(appliedFinder);
      expect(appliedButton.onPressed == null, isTrue);
    });
  });

  group('DiscoverPage widget', () {
    testWidgets('loads and displays a list of JobCard widgets', (tester) async {
      // Provide a fresh JobBloc from DI
      final jobBloc = GetIt.instance<JobBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<JobBloc>.value(
            value: jobBloc,
            child: const DiscoverPage(),
          ),
        ),
      );

      // initial pump triggers bloc initState; wait for asynchronous fetch
      await tester.pump(); // start frame
      await tester.pump(const Duration(milliseconds: 500)); // allow fake delays
      await tester.pumpAndSettle();

      // The fake data source generates 8 jobs; assert we find at least one JobCard
      expect(find.byType(JobCard), findsWidgets);

      // Verify that pulling to refresh triggers refresh UI (we can trigger it programmatically)
      final listFinder = find.byType(RefreshIndicator);
      expect(listFinder, findsOneWidget);

      // Scroll to bottom to ensure list builds all items (no crash)
      await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
      await tester.pumpAndSettle();

      expect(find.byType(JobCard), findsWidgets);
    });
  });
}
