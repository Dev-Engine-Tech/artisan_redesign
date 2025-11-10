import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:artisans_circle/features/invoices/presentation/pages/create_invoice_page.dart';
import 'package:artisans_circle/features/customers/domain/usecases/get_customers.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_my_catalog_items.dart';

class _FakeGetCustomers extends GetCustomers {
  _FakeGetCustomers() : super((_) => throw UnimplementedError());
  @override
  Future call({int page = 1, int limit = 50, String? searchQuery}) async => [];
}

class _FakeGetMyCatalogItems extends GetMyCatalogItems {
  _FakeGetMyCatalogItems() : super((_) => throw UnimplementedError());
  @override
  Future call({int page = 1}) async => [];
}

void main() {
  setUpAll(() {
    final getIt = GetIt.I;
    if (!getIt.isRegistered<GetCustomers>()) {
      getIt.registerLazySingleton<GetCustomers>(() => _FakeGetCustomers());
    }
    if (!getIt.isRegistered<GetMyCatalogItems>()) {
      getIt.registerLazySingleton<GetMyCatalogItems>(
          () => _FakeGetMyCatalogItems());
    }
  });

  Future<void> setSize(WidgetTester tester, Size size) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = size * 3; // assume DPR ~3
    binding.window.devicePixelRatioTestValue = 3.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });
  }

  testWidgets('no overflow on common iPhone logical size 390x844',
      (tester) async {
    await setSize(tester, const Size(390, 844));
    await tester.pumpWidget(const MaterialApp(home: CreateInvoicePage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('no overflow on smaller size 360x740 with keyboard-like inset',
      (tester) async {
    await setSize(tester, const Size(360, 740));
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.viewInsetsTestValue =
        const EdgeInsets.only(bottom: 300); // simulate keyboard
    await tester.pumpWidget(const MaterialApp(home: CreateInvoicePage()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    binding.window.clearViewInsetsTestValue();
  });
}
