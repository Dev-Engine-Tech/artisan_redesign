import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/discover_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_details_page.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/discover_job_card.dart';
import 'package:artisans_circle/features/home/presentation/pages/home_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/agreement_page.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    // Ensure DI uses the fake data source for deterministic widget tests
    await setupDependencies(useFake: true);
  });

  testWidgets('DiscoverPage shows job list and cards',
      (WidgetTester tester) async {
    // Render DiscoverPage without the heavy header to avoid tight layout in tests
    final widget = MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<AuthBloc>()),
          BlocProvider(create: (_) => getIt<JobBloc>()),
        ],
        child: const MaterialApp(home: DiscoverPage(showHeader: false)),
      ),
    );

    await tester.pumpWidget(widget);
    // allow async fake delays in data source to complete
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // DiscoverPage should be visible
    expect(find.byType(DiscoverPage), findsOneWidget);

    // There should be multiple DiscoverJobCard widgets (fake provides 8)
    expect(find.byType(DiscoverJobCard), findsWidgets);

    // At least one of the generated job titles should be present
    expect(find.text('Cushion Chair'), findsWidgets);
    expect(find.text('Electrical Home Wiring'), findsWidgets);
  });

  testWidgets('Tapping a job navigates to JobDetailsPage and shows details',
      (WidgetTester tester) async {
    final widget = MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<AuthBloc>()),
          BlocProvider(create: (_) => getIt<JobBloc>()),
        ],
        child: const MaterialApp(home: DiscoverPage(showHeader: false)),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap the first DiscoverJobCard widget (tapping the card ensures hit-test succeeds in tests)
    final cardFinder = find.byType(DiscoverJobCard).first;
    expect(cardFinder, findsOneWidget);

    await tester.tap(cardFinder);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // After navigation we expect JobDetailsPage to be visible
    expect(find.byType(JobDetailsPage), findsOneWidget);

    // JobDetailsPage shows description header (buttons are implementation details and may vary)
    expect(find.text('Description'), findsOneWidget);
  });

  testWidgets(
      'Applications tab: tapping an application opens Application (Agreement) page',
      (WidgetTester tester) async {
    final widget = MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<AuthBloc>()),
          BlocProvider(create: (_) => getIt<JobBloc>()),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Switch to Applications tab
    final applicationsTab = find.text('Applications');
    expect(applicationsTab, findsOneWidget);
    await tester.tap(applicationsTab);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Ensure there are JobCard widgets rendered for the Applications tab
    expect(find.byType(JobCard), findsWidgets);

    // Tap the first JobCard to open the full Application/Agreement page
    final appCard = find.byType(JobCard).first;
    await tester.tap(appCard);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // AgreementPage (full Application view) should be visible
    expect(find.byType(AgreementPage), findsOneWidget);

    // The AgreementPage AppBar title is 'Application'
    expect(find.text('Application'), findsOneWidget);

    // AgreementPage content should show 'Project Agreement' and the payment breakdown label
    expect(find.text('Project Agreement'), findsOneWidget);
    expect(find.textContaining('Agreed Payment', findRichText: false),
        findsOneWidget);
  });
}
