import 'package:flutter_test/flutter_test.dart';
import 'package:artisans_circle/features/invoices/presentation/cubit/invoice_form_cubit.dart';
import 'package:artisans_circle/features/customers/domain/usecases/get_customers.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_my_catalog_items.dart';

class _NoopGetCustomers extends GetCustomers {
  _NoopGetCustomers() : super((_) => throw UnimplementedError());
  @override
  Future call({int page = 1, int limit = 50, String? searchQuery}) async => [];
}

class _NoopGetCatalogs extends GetMyCatalogItems {
  _NoopGetCatalogs() : super((_) => throw UnimplementedError());
  @override
  Future call({int page = 1}) async => [];
}

void main() {
  test('grandTotal = lines + materials, updates on changes', () async {
    final cubit = InvoiceFormCubit(
      getCustomers: _NoopGetCustomers(),
      getMyCatalogItems: _NoopGetCatalogs(),
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
