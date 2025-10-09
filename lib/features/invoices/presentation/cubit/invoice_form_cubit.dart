import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:artisans_circle/features/customers/domain/entities/customer.dart';
import 'package:artisans_circle/features/customers/domain/usecases/get_customers.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_item.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_my_catalog_items.dart';
import 'package:artisans_circle/features/invoices/domain/entities/invoice.dart' as inv;

part 'invoice_form_state.dart';

class InvoiceFormCubit extends Cubit<InvoiceFormState> {
  final GetCustomers getCustomers;
  final GetMyCatalogItems getMyCatalogItems;

  InvoiceFormCubit({required this.getCustomers, required this.getMyCatalogItems})
      : super(const InvoiceFormState());

  Future<void> loadInitial() async {
    await Future.wait([loadCustomers(), loadCatalogs()]);
  }

  Future<void> loadCustomers() async {
    emit(state.copyWith(loadingCustomers: true, customersError: null));
    try {
      final list = await getCustomers(page: 1, limit: 50);
      emit(state.copyWith(loadingCustomers: false, customers: list));
    } catch (e) {
      emit(state.copyWith(loadingCustomers: false, customersError: e.toString()));
    }
  }

  Future<void> loadCatalogs() async {
    emit(state.copyWith(loadingCatalogs: true, catalogsError: null));
    try {
      final items = await getMyCatalogItems(page: 1);
      emit(state.copyWith(loadingCatalogs: false, catalogs: items));
    } catch (e) {
      emit(state.copyWith(loadingCatalogs: false, catalogsError: e.toString()));
    }
  }

  void selectCustomer(Customer c) {
    emit(state.copyWith(selectedCustomer: c));
  }

  void clearCustomer() {
    emit(state.copyWith(selectedCustomer: null));
  }

  // Helper to compute suggested unit price from a catalog item
  double suggestedPriceFromCatalog(CatalogItem c) {
    return (c.priceMax ?? c.priceMin ?? 0).toDouble();
  }

  // Totals ------------------------------------------------------------------
  double get invoiceLinesTotal {
    final sectionSum = state.sections
        .expand((s) => s.items)
        .fold<double>(0, (p, e) => p + e.subtotal);
    final indepSum =
        state.independentLines.fold<double>(0, (p, e) => p + e.subtotal);
    return sectionSum + indepSum;
  }

  Iterable<InvoiceLineData> get _allLines => [
        ...state.sections.expand((s) => s.items),
        ...state.independentLines,
      ];

  // Sum of quantity * unitPrice across all lines (before discounts/tax)
  double get lineBaseTotal =>
      _allLines.fold<double>(0, (p, e) => p + (e.quantity * e.unitPrice));

  // Sum of line discounts (absolute values) across all lines
  double get lineDiscountTotal =>
      _allLines.fold<double>(0, (p, e) => p + e.discount);

  // Sum of per-line tax across all lines
  double get lineTaxTotal => _allLines.fold<double>(0, (p, e) {
        final base = (e.quantity * e.unitPrice);
        final afterDiscount = (base - e.discount).clamp(0, double.infinity);
        return p + (afterDiscount * e.taxRate);
      });

  double get materialsTotal =>
      state.materials.fold<double>(0, (p, e) => p + e.subtotal);

  double get grandTotal => invoiceLinesTotal + materialsTotal;

  // Optional Taxes/Discounts ------------------------------------------------
  void setTaxRate(double valueFraction) {
    emit(state.copyWith(taxRate: valueFraction));
  }

  void setDiscount(double value) {
    emit(state.copyWith(discount: value));
  }

  double get subtotal => invoiceLinesTotal + materialsTotal;
  double get taxAmount => ((subtotal - state.discount).clamp(0, double.infinity)) * state.taxRate;
  double get grandTotalWithTax => (subtotal - state.discount).clamp(0, double.infinity) + taxAmount;

  // Hydration ---------------------------------------------------------------
  void hydrateFromInvoice(inv.Invoice invoice) {
    final lines = invoice.items
        .map((it) => InvoiceLineData(
              label: it.description,
              quantity: it.quantity.toDouble(),
              unitPrice: it.unitPrice,
            ))
        .toList();
    emit(state.copyWith(
      sections: const [],
      independentLines: lines,
      materials: const [],
      measurements: const [],
      taxRate: invoice.taxRate,
      // discount left as-is (0 by default)
    ));
  }

  // Lines / Sections --------------------------------------------------------
  void addSection() {
    final sections = List<InvoiceSectionData>.from(state.sections)
      ..add(const InvoiceSectionData(description: ''));
    emit(state.copyWith(sections: sections));
  }

  void removeSection(int index) {
    final sections = List<InvoiceSectionData>.from(state.sections)
      ..removeAt(index);
    emit(state.copyWith(sections: sections));
  }

  void updateSectionDescription(int index, String desc) {
    final sections = List<InvoiceSectionData>.from(state.sections);
    sections[index] = sections[index].copyWith(description: desc);
    emit(state.copyWith(sections: sections));
  }

  void addLineToSection(int sectionIndex) {
    final sections = List<InvoiceSectionData>.from(state.sections);
    final items = List<InvoiceLineData>.from(sections[sectionIndex].items)
      ..add(const InvoiceLineData(label: '', quantity: 1, unitPrice: 0));
    sections[sectionIndex] = sections[sectionIndex].copyWith(items: items);
    emit(state.copyWith(sections: sections));
  }

  void removeLineFromSection(int sectionIndex, int lineIndex) {
    final sections = List<InvoiceSectionData>.from(state.sections);
    final items = List<InvoiceLineData>.from(sections[sectionIndex].items)
      ..removeAt(lineIndex);
    sections[sectionIndex] = sections[sectionIndex].copyWith(items: items);
    emit(state.copyWith(sections: sections));
  }

  void updateLineInSection(int sectionIndex, int lineIndex,
      {String? label, double? quantity, double? unitPrice, String? catalogId, bool clearCatalog = false, double? discount, double? taxRate}) {
    final sections = List<InvoiceSectionData>.from(state.sections);
    final items = List<InvoiceLineData>.from(sections[sectionIndex].items);
    items[lineIndex] = items[lineIndex].copyWith(
      label: label,
      quantity: quantity,
      unitPrice: unitPrice,
      catalogId: catalogId,
      clearCatalog: clearCatalog,
      discount: discount,
      taxRate: taxRate,
    );
    sections[sectionIndex] = sections[sectionIndex].copyWith(items: items);
    emit(state.copyWith(sections: sections));
  }

  void addIndependentLine() {
    final lines = List<InvoiceLineData>.from(state.independentLines)
      ..add(const InvoiceLineData(label: '', quantity: 1, unitPrice: 0));
    emit(state.copyWith(independentLines: lines));
  }

  void removeIndependentLine(int index) {
    final lines = List<InvoiceLineData>.from(state.independentLines)
      ..removeAt(index);
    emit(state.copyWith(independentLines: lines));
  }

  void updateIndependentLine(int index,
      {String? label, double? quantity, double? unitPrice, String? catalogId, bool clearCatalog = false, double? discount, double? taxRate}) {
    final lines = List<InvoiceLineData>.from(state.independentLines);
    lines[index] = lines[index].copyWith(
      label: label,
      quantity: quantity,
      unitPrice: unitPrice,
      catalogId: catalogId,
      clearCatalog: clearCatalog,
      discount: discount,
      taxRate: taxRate,
    );
    emit(state.copyWith(independentLines: lines));
  }

  // Add helpers to create lines with initial data ---------------------------
  void addLineToSectionData(int sectionIndex, InvoiceLineData line) {
    final sections = List<InvoiceSectionData>.from(state.sections);
    final items = List<InvoiceLineData>.from(sections[sectionIndex].items)..add(line);
    sections[sectionIndex] = sections[sectionIndex].copyWith(items: items);
    emit(state.copyWith(sections: sections));
  }

  void addIndependentLineData(InvoiceLineData line) {
    final lines = List<InvoiceLineData>.from(state.independentLines)..add(line);
    emit(state.copyWith(independentLines: lines));
  }

  // Materials ---------------------------------------------------------------
  void addMaterial() {
    final list = List<InvoiceMaterialData>.from(state.materials)
      ..add(const InvoiceMaterialData(description: '', quantity: 1, unitPrice: 0));
    emit(state.copyWith(materials: list));
  }

  void removeMaterial(int index) {
    final list = List<InvoiceMaterialData>.from(state.materials)
      ..removeAt(index);
    emit(state.copyWith(materials: list));
  }

  void updateMaterial(int index, {String? description, double? quantity, double? unitPrice}) {
    final list = List<InvoiceMaterialData>.from(state.materials);
    list[index] = list[index].copyWith(
      description: description,
      quantity: quantity,
      unitPrice: unitPrice,
    );
    emit(state.copyWith(materials: list));
  }

  // Measurements ------------------------------------------------------------
  void addMeasurement() {
    final list = List<InvoiceMeasurementData>.from(state.measurements)
      ..add(const InvoiceMeasurementData(item: '', quantity: 1, uom: ''));
    emit(state.copyWith(measurements: list));
  }

  void removeMeasurement(int index) {
    final list = List<InvoiceMeasurementData>.from(state.measurements)
      ..removeAt(index);
    emit(state.copyWith(measurements: list));
  }

  void updateMeasurement(int index, {String? item, double? quantity, String? uom}) {
    final list = List<InvoiceMeasurementData>.from(state.measurements);
    list[index] = list[index].copyWith(item: item, quantity: quantity, uom: uom);
    emit(state.copyWith(measurements: list));
  }
}
