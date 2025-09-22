import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/discover_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_details_page.dart';
import 'package:artisans_circle/features/jobs/data/models/job_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Use fake data source so rendering is deterministic
    await setupDependencies(useFake: true);
  });

  // NOTE:
  // These are golden tests. To create/update the golden images run:
  //   flutter test --update-goldens
  //
  // The first run without --update-goldens will fail because the golden files
  // don't exist yet. Running with --update-goldens will generate the reference
  // images which you can commit and use to ensure pixel-perfect regressions.

  testWidgets('DiscoverPage golden', (WidgetTester tester) async {
    final widget = MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: const MaterialApp(home: DiscoverPage(showHeader: true)),
    );

    await tester.pumpWidget(widget);
    // Wait for async fake datasource to populate
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await expectLater(
      find.byType(DiscoverPage),
      matchesGoldenFile('goldens/discover_page.png'),
    );
  });

  testWidgets('JobDetailsPage golden', (WidgetTester tester) async {
    // Create a sample job model (matches fake datasource shape)
    final job = JobModel(
      id: 'golden_job',
      title: 'Cushion Chair',
      category: 'Furniture',
      description:
          'Lorem ipsum dolor sit amet consectetur. Brief description used for golden rendering.',
      address: 'Demo address',
      minBudget: 150,
      maxBudget: 200,
      duration: 'Less than a month',
      applied: false,
      thumbnailUrl: '',
    ).toEntity();

    final widget = MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: MaterialApp(home: JobDetailsPage(job: job)),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await expectLater(
      find.byType(JobDetailsPage),
      matchesGoldenFile('goldens/job_details_page.png'),
    );
  });
}
