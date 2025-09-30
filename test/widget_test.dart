import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/discover_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // ensure DI uses fake data source for widget tests
    SharedPreferences.setMockInitialValues({});
    await setupDependencies(useFake: true);
  });

  testWidgets('App builds and shows DiscoverPage', (WidgetTester tester) async {
    // Provide a realistic device size via MediaQuery to avoid layout overflow in tests
    final mq = MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: const MaterialApp(home: DiscoverPage()),
    );

    await tester.pumpWidget(mq);
    await tester.pumpAndSettle();

    // DiscoverPage should be visible
    expect(find.byType(DiscoverPage), findsOneWidget);
  });
}
