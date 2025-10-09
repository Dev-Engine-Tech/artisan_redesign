import 'package:artisans_circle/features/catalog/domain/entities/catalog_item.dart';
import 'package:artisans_circle/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_my_catalog_items.dart';
import 'package:artisans_circle/features/customers/domain/entities/customer.dart';
import 'package:artisans_circle/features/customers/domain/usecases/get_customers.dart';
import 'package:artisans_circle/features/invoices/presentation/pages/create_invoice_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakeGetCustomers extends GetCustomers {
  _FakeGetCustomers() : super((_) => throw UnimplementedError());
  @override
  Future<List<Customer>> call({int page = 1, int limit = 50, String? searchQuery}) async {
    return [
      Customer(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        address: '123 Street',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      ),
      Customer(
        id: '2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      ),
    ];
  }
}

void main() {
  final getIt = GetIt.I;

  setUpAll(() {
    if (!getIt.isRegistered<GetMyCatalogItems>()) {
      final fakeRepo = _FakeCatalogRepository();
      getIt.registerLazySingleton<GetMyCatalogItems>(() => GetMyCatalogItems(fakeRepo));
    }
    if (!getIt.isRegistered<GetCustomers>()) {
      getIt.registerLazySingleton<GetCustomers>(() => _FakeGetCustomers());
    }
  });

  testWidgets('customer picker selects customer and fills address', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateInvoicePage()));
    await tester.pumpAndSettle();

    // Tap customer picker icon
    final customerIcon = find.byIcon(Icons.people_outline).first;
    expect(customerIcon, findsOneWidget);
    await tester.tap(customerIcon);
    await tester.pumpAndSettle();

    // Tap first customer
    await tester.tap(find.text('John Doe'));
    await tester.pumpAndSettle();

    // Verify field updated
    expect(find.text('John Doe'), findsWidgets);
    expect(find.text('123 Street'), findsOneWidget);
  });

  testWidgets('invoice line label preview shows typed label', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateInvoicePage()));
    await tester.pumpAndSettle();

    // Switch to Invoice Lines tab if not default; Add Line
    final addLine = find.widgetWithText(ElevatedButton, 'Add Line');
    expect(addLine, findsOneWidget);
    await tester.tap(addLine);
    await tester.pumpAndSettle();

    // Enter label in first line (TextField with hint contains 'Label')
    final labelField = find.byType(TextField).first;
    await tester.enterText(labelField, 'My Service');
    await tester.pumpAndSettle();

    // Preview chip should show 'My Service'
    expect(find.text('My Service'), findsWidgets);
  });

  testWidgets('catalog selection uses priceMax then falls back to priceMin', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateInvoicePage()));
    await tester.pumpAndSettle();

    // Add a line
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Line'));
    await tester.pumpAndSettle();

    // Open catalog picker via storefront icon
    final storeIcon = find.byIcon(Icons.storefront_outlined).first;
    await tester.tap(storeIcon);
    await tester.pumpAndSettle();

    // Tap first catalog (has priceMax 5000)
    await tester.tap(find.text('Catalog Max Only'));
    await tester.pumpAndSettle();
    // Subtotal should be NGN 5000.00 (quantity default 1)
    expect(find.text('NGN 5000.00'), findsWidgets);

    // Add another line
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Line'));
    await tester.pumpAndSettle();

    // Open catalog picker for second line (tap last icon)
    final storeIcons = find.byIcon(Icons.storefront_outlined);
    await tester.tap(storeIcons.last);
    await tester.pumpAndSettle();

    // Tap second catalog (has only priceMin 3000)
    await tester.tap(find.text('Catalog Min Only'));
    await tester.pumpAndSettle();
    expect(find.text('NGN 3000.00'), findsWidgets);
  });
}

class _FakeCatalogRepository implements CatalogRepository {
  @override
  Future<CatalogItem> createCatalog({required String title, required String subCategoryId, required String description, int? priceMin, int? priceMax, String? projectTimeline, List<String> imagePaths = const [], bool instantSelling = false, String? brand, String? condition, String? salesCategory, bool warranty = false, bool delivery = false}) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteCatalog(String id) async => throw UnimplementedError();

  @override
  Future<List<CatalogItem>> getCatalogByUser(String userId, {int page = 1}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<CatalogItem>> getMyCatalogItems({int page = 1}) async {
    return [
      CatalogItem(
        id: 'cat1',
        title: 'Catalog Max Only',
        description: 'desc',
        priceMin: null,
        priceMax: 5000,
        projectTimeline: null,
        imageUrl: null,
        ownerName: null,
        status: null,
        projectStatus: null,
      ),
      CatalogItem(
        id: 'cat2',
        title: 'Catalog Min Only',
        description: 'desc',
        priceMin: 3000,
        priceMax: null,
        projectTimeline: null,
        imageUrl: null,
        ownerName: null,
        status: null,
        projectStatus: null,
      ),
    ];
  }

  @override
  Future<CatalogItem> updateCatalog({required String id, String? title, String? subCategoryId, String? description, int? priceMin, int? priceMax, String? projectTimeline, List<String> newImagePaths = const [], bool? instantSelling, String? brand, String? condition, String? salesCategory, bool? warranty, bool? delivery}) async {
    throw UnimplementedError();
  }
}
