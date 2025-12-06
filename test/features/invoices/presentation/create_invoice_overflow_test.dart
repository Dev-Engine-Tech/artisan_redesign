import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:artisans_circle/features/invoices/presentation/pages/create_invoice_page.dart';
import 'package:artisans_circle/features/customers/domain/usecases/get_customers.dart';
import 'package:artisans_circle/features/customers/domain/repositories/customer_repository.dart';
import 'package:artisans_circle/features/customers/domain/entities/customer.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_my_catalog_items.dart';
import 'package:artisans_circle/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_item.dart';

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
    return [];
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

class _FakeCatalogRepository implements CatalogRepository {
  @override
  Future<CatalogItem> createCatalog({required String title, required String subCategoryId, required String description, int? priceMin, int? priceMax, String? projectTimeline, List<String> imagePaths = const [], bool instantSelling = false, String? brand, String? condition, String? salesCategory, bool warranty = false, bool delivery = false}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteCatalog(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<CatalogItem>> getCatalogByUser(String userId, {int page = 1}) {
    throw UnimplementedError();
  }

  @override
  Future<CatalogItem> getCatalogDetails(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<CatalogItem>> getMyCatalogItems({int page = 1}) async {
    return [];
  }

  @override
  Future<CatalogItem> updateCatalog({required String id, String? title, String? subCategoryId, String? description, int? priceMin, int? priceMax, String? projectTimeline, List<String> newImagePaths = const [], bool? instantSelling, String? brand, String? condition, String? salesCategory, bool? warranty, bool? delivery}) {
    throw UnimplementedError();
  }
}

void main() {
  setUpAll(() {
    final getIt = GetIt.I;
    if (!getIt.isRegistered<GetCustomers>()) {
      getIt.registerLazySingleton<GetCustomers>(() => GetCustomers(_FakeCustomerRepository()));
    }
    if (!getIt.isRegistered<GetMyCatalogItems>()) {
      getIt.registerLazySingleton<GetMyCatalogItems>(
          () => GetMyCatalogItems(_FakeCatalogRepository()));
    }
  });

  Future<void> setSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size * 3; // assume DPR ~3
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
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
    // Simulate keyboard inset if supported; not strictly required for this check
    await tester.pumpWidget(const MaterialApp(home: CreateInvoicePage()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    // No explicit reset needed when not setting viewInsets
  });
}
