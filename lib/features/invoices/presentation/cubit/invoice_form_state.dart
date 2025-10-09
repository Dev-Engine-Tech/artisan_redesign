part of 'invoice_form_cubit.dart';

class InvoiceFormState extends Equatable {
  final List<Customer> customers;
  final bool loadingCustomers;
  final String? customersError;
  final Customer? selectedCustomer;

  final List<CatalogItem> catalogs;
  final bool loadingCatalogs;
  final String? catalogsError;

  // Form data
  final List<InvoiceSectionData> sections;
  final List<InvoiceLineData> independentLines;
  final List<InvoiceMaterialData> materials;
  final List<InvoiceMeasurementData> measurements;
  final double taxRate; // fraction (e.g., 0.075 for 7.5%)
  final double discount; // absolute amount

  const InvoiceFormState({
    this.customers = const [],
    this.loadingCustomers = false,
    this.customersError,
    this.selectedCustomer,
    this.catalogs = const [],
    this.loadingCatalogs = false,
    this.catalogsError,
    this.sections = const [],
    this.independentLines = const [],
    this.materials = const [],
    this.measurements = const [],
    this.taxRate = 0.0,
    this.discount = 0.0,
  });

  InvoiceFormState copyWith({
    List<Customer>? customers,
    bool? loadingCustomers,
    String? customersError,
    Customer? selectedCustomer,
    bool clearSelectedCustomer = false,
    List<CatalogItem>? catalogs,
    bool? loadingCatalogs,
    String? catalogsError,
    List<InvoiceSectionData>? sections,
    List<InvoiceLineData>? independentLines,
    List<InvoiceMaterialData>? materials,
    List<InvoiceMeasurementData>? measurements,
    double? taxRate,
    double? discount,
  }) {
    return InvoiceFormState(
      customers: customers ?? this.customers,
      loadingCustomers: loadingCustomers ?? this.loadingCustomers,
      customersError: customersError ?? this.customersError,
      selectedCustomer:
          clearSelectedCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      catalogs: catalogs ?? this.catalogs,
      loadingCatalogs: loadingCatalogs ?? this.loadingCatalogs,
      catalogsError: catalogsError ?? this.catalogsError,
      sections: sections ?? this.sections,
      independentLines: independentLines ?? this.independentLines,
      materials: materials ?? this.materials,
      measurements: measurements ?? this.measurements,
      taxRate: taxRate ?? this.taxRate,
      discount: discount ?? this.discount,
    );
  }

  @override
  List<Object?> get props => [
        customers,
        loadingCustomers,
        customersError,
        selectedCustomer,
        catalogs,
        loadingCatalogs,
        catalogsError,
        sections,
        independentLines,
        materials,
        measurements,
        taxRate,
        discount,
      ];
}

class InvoiceLineData extends Equatable {
  final String label;
  final double quantity;
  final double unitPrice;
  final String? catalogId;
  final double discount; // absolute amount per line
  final double taxRate; // fraction per line (e.g., 0.05)

  const InvoiceLineData({
    required this.label,
    required this.quantity,
    required this.unitPrice,
    this.catalogId,
    this.discount = 0.0,
    this.taxRate = 0.0,
  });

  double get subtotal {
    final base = (quantity * unitPrice);
    final afterDiscount = (base - discount).clamp(0, double.infinity);
    final tax = afterDiscount * taxRate;
    return afterDiscount + tax;
  }

  InvoiceLineData copyWith({
    String? label,
    double? quantity,
    double? unitPrice,
    String? catalogId,
    bool clearCatalog = false,
    double? discount,
    double? taxRate,
  }) {
    return InvoiceLineData(
      label: label ?? this.label,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      catalogId: clearCatalog ? null : (catalogId ?? this.catalogId),
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  @override
  List<Object?> get props => [label, quantity, unitPrice, catalogId, discount, taxRate];
}

class InvoiceSectionData extends Equatable {
  final String description;
  final List<InvoiceLineData> items;

  const InvoiceSectionData({required this.description, this.items = const []});

  InvoiceSectionData copyWith({String? description, List<InvoiceLineData>? items}) {
    return InvoiceSectionData(
      description: description ?? this.description,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [description, items];
}

class InvoiceMaterialData extends Equatable {
  final String description;
  final double quantity;
  final double unitPrice;

  const InvoiceMaterialData({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  InvoiceMaterialData copyWith({String? description, double? quantity, double? unitPrice}) {
    return InvoiceMaterialData(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  List<Object?> get props => [description, quantity, unitPrice];
}

class InvoiceMeasurementData extends Equatable {
  final String item;
  final double quantity;
  final String uom;

  const InvoiceMeasurementData({required this.item, required this.quantity, required this.uom});

  InvoiceMeasurementData copyWith({String? item, double? quantity, String? uom}) {
    return InvoiceMeasurementData(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      uom: uom ?? this.uom,
    );
  }

  @override
  List<Object?> get props => [item, quantity, uom];
}
