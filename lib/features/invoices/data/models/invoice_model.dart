import '../../domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.clientName,
    required super.clientEmail,
    super.customerId,
    super.deliveryAddress,
    super.currency,
    required super.issueDate,
    required super.dueDate,
    required super.items,
    super.materials,
    super.measurements,
    required super.subtotal,
    required super.taxRate,
    required super.taxAmount,
    required super.total,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.notes,
    super.jobId,
    super.paidDate,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    T? pick<T>(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k] as T;
      }
      return null;
    }

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    String _pickId() => pick<String>(['id', 'uuid', 'invoice_id']) ?? '';
    String _pickInvoiceNumber() =>
        pick<String>(['invoiceNumber', 'invoice_number', 'number']) ?? '';
    String _pickClientName() =>
        pick<String>(['clientName', 'client_name', 'customer_name']) ?? '';
    String _pickClientEmail() =>
        pick<String>(['clientEmail', 'client_email', 'customer_email']) ?? '';
    String? _pickCustomerId() =>
        pick<String>(['customer', 'customer_id', 'customer_uuid']);

    DateTime _parseDate(List<String> keys) {
      final v = pick<dynamic>(keys);
      if (v is String) {
        return DateTime.tryParse(v) ?? DateTime.now();
      }
      return DateTime.now();
    }

    DateTime? _parseOptionalDate(List<String> keys) {
      final v = pick<dynamic>(keys);
      if (v is String) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    final itemsRaw =
        pick<List<dynamic>>(['items', 'line_items', 'invoice_items']) ??
            const [];
    final List<InvoiceItem> items = itemsRaw
        .whereType<Map>()
        .map((e) => InvoiceItemModel.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v))))
        .toList()
        .cast<InvoiceItem>();

    final matsRaw =
        json['materials'] is List ? List.from(json['materials']) : const [];
    final List<InvoiceMaterial> materials = matsRaw
        .whereType<Map>()
        .map((e) => InvoiceMaterialModel.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        .cast<InvoiceMaterial>();

    final measRaw = json['measurements'] is List
        ? List.from(json['measurements'])
        : const [];
    final List<InvoiceMeasurement> measurements = measRaw
        .whereType<Map>()
        .map((e) =>
            InvoiceMeasurementModel.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        .cast<InvoiceMeasurement>();

    final rawStatus = pick<String>(['status', 'invoice_status']) ?? 'draft';
    final statusStr = rawStatus.toString().toLowerCase();
    InvoiceStatus mapStatus(String s) {
      switch (s) {
        case 'validated':
        case 'confirm':
        case 'confirmed':
        case 'sent':
          return InvoiceStatus.validated;
        case 'paid':
          return InvoiceStatus.paid;
        case 'pending':
          return InvoiceStatus.pending;
        case 'overdue':
          return InvoiceStatus.overdue;
        case 'cancelled':
        case 'canceled':
          return InvoiceStatus.cancelled;
        case 'draft':
        default:
          return InvoiceStatus.draft;
      }
    }

    final status = InvoiceStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == statusStr,
      orElse: () => mapStatus(statusStr),
    );

    return InvoiceModel(
      id: _pickId(),
      invoiceNumber: _pickInvoiceNumber(),
      clientName: _pickClientName(),
      clientEmail: _pickClientEmail(),
      deliveryAddress: pick(['delivery_address']),
      currency: pick(['currency']),
      issueDate: _parseDate(['issueDate', 'issue_date', 'created_at']),
      dueDate: _parseDate(['dueDate', 'due_date']),
      items: items,
      materials: materials,
      measurements: measurements,
      subtotal: _toDouble(pick(['subtotal', 'subtotal_amount'])),
      taxRate: _toDouble(pick(['taxRate', 'tax_rate'])),
      taxAmount: _toDouble(pick(['taxAmount', 'tax_amount'])),
      total: _toDouble(pick(['total', 'total_amount'])),
      status: status,
      notes: pick(['notes', 'note']),
      jobId: pick(['jobId', 'job_id']),
      customerId: _pickCustomerId(),
      paidDate: _parseOptionalDate(['paidDate', 'paid_date']),
      createdAt: _parseDate(['createdAt', 'created_at']),
      updatedAt: _parseDate(['updatedAt', 'updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': id,
      'invoice_number': invoiceNumber,
      'invoiceNumber': invoiceNumber,
      'client_name': clientName,
      'clientName': clientName,
      'client_email': clientEmail,
      'clientEmail': clientEmail,
      if (customerId != null) 'customer': customerId,
      if (customerId != null) 'customer_id': customerId,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (currency != null) 'currency': currency,
      'issue_date': issueDate.toIso8601String(),
      'issueDate': issueDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'items': items
          .map((item) => InvoiceItemModel.fromEntity(item).toJson())
          .toList(),
      'line_items': items
          .map((item) => InvoiceItemModel.fromEntity(item).toJson())
          .toList(),
      if (materials != null)
        'materials': materials!
            .map((m) => InvoiceMaterialModel.fromEntity(m).toJson())
            .toList(),
      if (measurements != null)
        'measurements': measurements!
            .map((m) => InvoiceMeasurementModel.fromEntity(m).toJson())
            .toList(),
      'subtotal': subtotal,
      'subtotal_amount': subtotal,
      'tax_rate': taxRate,
      'taxRate': taxRate,
      'tax_amount': taxAmount,
      'taxAmount': taxAmount,
      'total': total,
      'total_amount': total,
      'status': status.name,
      'notes': notes,
      'note': notes,
      'job_id': jobId,
      'jobId': jobId,
      'paid_date': paidDate?.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InvoiceModel.fromEntity(Invoice invoice) {
    return InvoiceModel(
      id: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      clientName: invoice.clientName,
      clientEmail: invoice.clientEmail,
      customerId: invoice.customerId,
      deliveryAddress: invoice.deliveryAddress,
      currency: invoice.currency,
      issueDate: invoice.issueDate,
      dueDate: invoice.dueDate,
      items: invoice.items
          .map((item) => InvoiceItemModel.fromEntity(item))
          .toList(),
      materials: invoice.materials,
      measurements: invoice.measurements,
      subtotal: invoice.subtotal,
      taxRate: invoice.taxRate,
      taxAmount: invoice.taxAmount,
      total: invoice.total,
      status: invoice.status,
      notes: invoice.notes,
      jobId: invoice.jobId,
      paidDate: invoice.paidDate,
      createdAt: invoice.createdAt,
      updatedAt: invoice.updatedAt,
    );
  }

  Invoice toEntity() => Invoice(
        id: id,
        invoiceNumber: invoiceNumber,
        clientName: clientName,
        clientEmail: clientEmail,
        customerId: customerId,
        deliveryAddress: deliveryAddress,
        currency: currency,
        issueDate: issueDate,
        dueDate: dueDate,
        items:
            items.map((item) => (item as InvoiceItemModel).toEntity()).toList(),
        materials: materials,
        measurements: measurements,
        subtotal: subtotal,
        taxRate: taxRate,
        taxAmount: taxAmount,
        total: total,
        status: status,
        notes: notes,
        jobId: jobId,
        paidDate: paidDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

class InvoiceItemModel extends InvoiceItem {
  const InvoiceItemModel({
    required super.id,
    required super.description,
    required super.quantity,
    required super.unitPrice,
    required super.amount,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    T? pick<T>(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k] as T;
      }
      return null;
    }

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) {
        final cleaned = v.replaceAll(RegExp(r'[^0-9\.-]'), '');
        if (cleaned.isEmpty) return 0.0;
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) {
        final cleaned = v.replaceAll(RegExp(r'[^0-9\.-]'), '');
        final di = int.tryParse(cleaned);
        if (di != null) return di;
        final dd = double.tryParse(cleaned);
        return dd?.round() ?? 0;
      }
      return 0;
    }

    return InvoiceItemModel(
      id: pick<String>(['id', 'uuid', 'item_id']) ?? '',
      description:
          pick<String>(['description', 'desc', 'item_description']) ?? '',
      quantity: _toInt(pick(['quantity', 'qty'])),
      unitPrice: _toDouble(pick(['unitPrice', 'unit_price', 'price'])),
      amount: _toDouble(pick(['amount', 'line_total', 'total'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': id,
      'description': description,
      'item_description': description,
      'quantity': quantity,
      'qty': quantity,
      'unitPrice': unitPrice,
      'unit_price': unitPrice,
      'amount': amount,
      'line_total': amount,
    };
  }

  factory InvoiceItemModel.fromEntity(InvoiceItem item) {
    return InvoiceItemModel(
      id: item.id,
      description: item.description,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      amount: item.amount,
    );
  }

  InvoiceItem toEntity() => InvoiceItem(
        id: id,
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
        amount: amount,
      );
}

class InvoiceMaterialModel extends InvoiceMaterial {
  const InvoiceMaterialModel({
    super.id,
    required super.name,
    super.description,
    required super.quantity,
    required super.unit,
    required super.unitCost,
  });

  factory InvoiceMaterialModel.fromEntity(InvoiceMaterial m) =>
      InvoiceMaterialModel(
        id: m.id,
        name: m.name,
        description: m.description,
        quantity: m.quantity,
        unit: m.unit,
        unitCost: m.unitCost,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'description': description,
        'quantity': quantity,
        'unit': unit,
        'unit_cost': unitCost,
      };

  factory InvoiceMaterialModel.fromJson(Map<String, dynamic> json) =>
      InvoiceMaterialModel(
        id: json['id']?.toString(),
        name: (json['name'] ?? json['description'] ?? '').toString(),
        description: json['description']?.toString(),
        quantity: (json['quantity'] is num)
            ? (json['quantity'] as num).toDouble()
            : double.tryParse(json['quantity']?.toString() ?? '') ?? 0,
        unit: (json['unit'] ?? 'unit').toString(),
        unitCost: (json['unit_cost'] is num)
            ? (json['unit_cost'] as num).toDouble()
            : double.tryParse(json['unit_cost']?.toString() ?? '') ?? 0,
      );
}

class InvoiceMeasurementModel extends InvoiceMeasurement {
  const InvoiceMeasurementModel({
    super.id,
    required super.label,
    required super.value,
    required super.unit,
    super.notes,
  });

  factory InvoiceMeasurementModel.fromEntity(InvoiceMeasurement m) =>
      InvoiceMeasurementModel(
        id: m.id,
        label: m.label,
        value: m.value,
        unit: m.unit,
        notes: m.notes,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'label': label,
        'value': value,
        'unit': unit,
        'notes': notes,
      };

  factory InvoiceMeasurementModel.fromJson(Map<String, dynamic> json) =>
      InvoiceMeasurementModel(
        id: json['id']?.toString(),
        label: (json['label'] ?? '').toString(),
        value: (json['value'] is num)
            ? (json['value'] as num).toDouble()
            : double.tryParse(json['value']?.toString() ?? '') ?? 0,
        unit: (json['unit'] ?? 'unit').toString(),
        notes: json['notes']?.toString(),
      );
}
