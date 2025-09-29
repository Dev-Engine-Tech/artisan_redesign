import '../../domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.clientName,
    required super.clientEmail,
    required super.issueDate,
    required super.dueDate,
    required super.items,
    required super.subtotal,
    required super.taxRate,
    required super.taxAmount,
    required super.total,
    required super.status,
    super.notes,
    super.jobId,
    super.paidDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      clientName: json['clientName'],
      clientEmail: json['clientEmail'],
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: DateTime.parse(json['dueDate']),
      items: (json['items'] as List).map((item) => InvoiceItemModel.fromJson(item)).toList(),
      subtotal: json['subtotal'].toDouble(),
      taxRate: json['taxRate'].toDouble(),
      taxAmount: json['taxAmount'].toDouble(),
      total: json['total'].toDouble(),
      status: InvoiceStatus.values.byName(json['status']),
      notes: json['notes'],
      jobId: json['jobId'],
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'items': items.map((item) => InvoiceItemModel.fromEntity(item).toJson()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'total': total,
      'status': status.name,
      'notes': notes,
      'jobId': jobId,
      'paidDate': paidDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InvoiceModel.fromEntity(Invoice invoice) {
    return InvoiceModel(
      id: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      clientName: invoice.clientName,
      clientEmail: invoice.clientEmail,
      issueDate: invoice.issueDate,
      dueDate: invoice.dueDate,
      items: invoice.items.map((item) => InvoiceItemModel.fromEntity(item)).toList(),
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
        issueDate: issueDate,
        dueDate: dueDate,
        items: items.map((item) => (item as InvoiceItemModel).toEntity()).toList(),
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
    return InvoiceItemModel(
      id: json['id'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      amount: json['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'amount': amount,
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
