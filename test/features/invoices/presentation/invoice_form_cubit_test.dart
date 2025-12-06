import 'package:flutter_test/flutter_test.dart';
import 'package:artisans_circle/features/invoices/presentation/cubit/invoice_form_cubit.dart';
import 'package:artisans_circle/features/customers/domain/usecases/get_customers.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_my_catalog_items.dart';
import 'package:artisans_circle/features/customers/domain/repositories/customer_repository.dart';
import 'package:artisans_circle/features/customers/domain/entities/customer.dart';
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
  test('grandTotal = lines + materials, updates on changes', () async {
    final cubit = InvoiceFormCubit(
      getCustomers: GetCustomers(_FakeCustomerRepository()),
      getMyCatalogItems: GetMyCatalogItems(_FakeCatalogRepository()),
    );

    // Start empty
    expect(cubit.invoiceLinesTotal, 0);
    expect(cubit.materialsTotal, 0);
    expect(cubit.grandTotal, 0);

    // Add independent line: 2 * 1000 = 2000
    cubit.addIndependentLine();
    cubit.updateIndependentLine(0, quantity: 2, unitPrice: 1000);
    expect(cubit.invoiceLinesTotal, 2000);
    expect(cubit.grandTotal, 2000);

    // Add material: 3 * 500 = 1500 -> grand = 3500
    cubit.addMaterial();
    cubit.updateMaterial(0, quantity: 3, unitPrice: 500);
    expect(cubit.materialsTotal, 1500);
    expect(cubit.grandTotal, 3500);

    // Add section line: 1 * 2500 = 2500 -> lines = 4500, grand = 6000
    cubit.addSection();
    cubit.addLineToSection(0);
    cubit.updateLineInSection(0, 0, unitPrice: 2500);
    expect(cubit.invoiceLinesTotal, 4500);
    expect(cubit.grandTotal, 6000);

    // Apply discount 1000, tax 10% (0.10)
    cubit.setDiscount(1000);
    cubit.setTaxRate(0.10);
    // subtotal = 4500 (lines) + 1500 (materials) = 6000
    // after discount: 5000; tax 10% = 500; total = 5500
    expect(cubit.subtotal, 6000);
    expect(cubit.taxAmount.toStringAsFixed(2), '500.00');
    expect(cubit.grandTotalWithTax.toStringAsFixed(2), '5500.00');
  });
}
