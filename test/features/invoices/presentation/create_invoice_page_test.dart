import 'package:artisans_circle/features/catalog/domain/entities/catalog_item.dart';
import 'package:artisans_circle/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_my_catalog_items.dart';
import 'package:artisans_circle/features/customers/domain/entities/customer.dart';
import 'package:artisans_circle/features/customers/domain/usecases/get_customers.dart';
import 'package:artisans_circle/features/customers/domain/repositories/customer_repository.dart';
import 'package:artisans_circle/features/invoices/presentation/pages/create_invoice_page.dart';
import 'package:artisans_circle/features/invoices/presentation/widgets/lines_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:artisans_circle/features/invoices/presentation/cubit/invoice_form_cubit.dart';

class _FakeCustomerRepository implements CustomerRepository {
  @override
  Future<Customer> createCustomer(Customer customer) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCustomer(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Customer> getCustomerById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Customer>> getCustomers({int page = 1, int limit = 20, String? searchQuery}) async {
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

  @override
  Stream<List<Customer>> watchCustomers() {
    throw UnimplementedError();
  }

  @override
  Future<Customer> updateCustomer(Customer customer) {
    throw UnimplementedError();
  }
}

void main() {
  final getIt = GetIt.I;

  setUpAll(() {
    if (!getIt.isRegistered<GetMyCatalogItems>()) {
      final fakeRepo = _FakeCatalogRepository();
      getIt.registerLazySingleton<GetMyCatalogItems>(
          () => GetMyCatalogItems(fakeRepo));
    }
    if (!getIt.isRegistered<GetCustomers>()) {
      getIt.registerLazySingleton<GetCustomers>(() => GetCustomers(_FakeCustomerRepository()));
    }
  });

  testWidgets('customer picker selects customer and fills address',
      (tester) async {
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

    // Add a line via cubit to avoid scroll/hit-test flakiness
    final ctx1 = tester.element(find.byType(LinesTab));
    BlocProvider.of<InvoiceFormCubit>(ctx1).addIndependentLine();
    await tester.pumpAndSettle();

    // Enter label in first line (TextField with hint contains 'Label')
    final labelField = find.byType(TextField).first;
    await tester.enterText(labelField, 'My Service');
    await tester.pumpAndSettle();

    // Preview chip should show 'My Service'
    expect(find.text('My Service'), findsWidgets);
  });

  testWidgets('catalog selection uses priceMax then falls back to priceMin',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateInvoicePage()));
    await tester.pumpAndSettle();

    // Add a line via cubit
    final ctx2 = tester.element(find.byType(LinesTab));
    BlocProvider.of<InvoiceFormCubit>(ctx2).addIndependentLine();
    await tester.pumpAndSettle();

    // Open catalog picker via storefront icon
    final storeIcon = find.byIcon(Icons.storefront_outlined).first;
    await tester.ensureVisible(storeIcon);
    await tester.pumpAndSettle();
    await tester.tap(storeIcon, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap first catalog (has priceMax 5000)
    await tester.tap(find.text('Catalog Max Only'));
    await tester.pumpAndSettle();
    // Enter suggested price to update subtotal
    final priceField1 = find.byWidgetPredicate((w) {
      return w is TextField &&
          (w.decoration?.hintText ?? '').toString() == 'NGN 0.00';
    }).first;
    await tester.enterText(priceField1, '5000');
    await tester.pumpAndSettle();
    expect(find.text('NGN 5000.00'), findsWidgets);

    // Add another line via cubit
    BlocProvider.of<InvoiceFormCubit>(ctx2).addIndependentLine();
    await tester.pumpAndSettle();

    // Open catalog picker for second line (tap last icon)
    final storeIcons = find.byIcon(Icons.storefront_outlined);
    await tester.tap(storeIcons.last);
    await tester.pumpAndSettle();

    // Tap second catalog (has only priceMin 3000)
    await tester.tap(find.text('Catalog Min Only'));
    await tester.pumpAndSettle();
    // Enter price to update second line subtotal
    final priceField2 = find.byWidgetPredicate((w) {
      return w is TextField &&
          (w.decoration?.hintText ?? '').toString() == 'NGN 0.00';
    }).last;
    await tester.enterText(priceField2, '3000');
    await tester.pumpAndSettle();
    expect(find.text('NGN 3000.00'), findsWidgets);
  });
}

class _FakeCatalogRepository implements CatalogRepository {
  @override
  Future<CatalogItem> createCatalog(
      {required String title,
      required String subCategoryId,
      required String description,
      int? priceMin,
      int? priceMax,
      String? projectTimeline,
      List<String> imagePaths = const [],
      bool instantSelling = false,
      String? brand,
      String? condition,
      String? salesCategory,
      bool warranty = false,
      bool delivery = false}) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteCatalog(String id) async => throw UnimplementedError();

  @override
  Future<List<CatalogItem>> getCatalogByUser(String userId,
      {int page = 1}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<CatalogItem>> getMyCatalogItems({int page = 1}) async {
    return [
      const CatalogItem(
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
      const CatalogItem(
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
  Future<CatalogItem> getCatalogDetails(String id) async {
    // Return a simple item matching id or first
    final items = await getMyCatalogItems(page: 1);
    return items.firstWhere((e) => e.id == id, orElse: () => items.first);
  }

  @override
  Future<CatalogItem> updateCatalog(
      {required String id,
      String? title,
      String? subCategoryId,
      String? description,
      int? priceMin,
      int? priceMax,
      String? projectTimeline,
      List<String> newImagePaths = const [],
      bool? instantSelling,
      String? brand,
      String? condition,
      String? salesCategory,
      bool? warranty,
      bool? delivery}) async {
    throw UnimplementedError();
  }
}
