import 'package:equatable/equatable.dart';

enum InvoiceStatus { draft, pending, validated, paid, overdue, cancelled }

class Invoice extends Equatable {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final String clientEmail;
  final String? customerId;
  final String? deliveryAddress;
  final String? currency; // e.g., NGN
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final List<InvoiceMaterial>? materials;
  final List<InvoiceMeasurement>? measurements;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final InvoiceStatus status;
  final String? notes;
  final String? jobId;
  final DateTime? paidDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    required this.clientEmail,
    this.customerId,
    this.deliveryAddress,
    this.currency,
    required this.issueDate,
    required this.dueDate,
    required this.items,
    this.materials,
    this.measurements,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.jobId,
    this.paidDate,
  });

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? clientName,
    String? clientEmail,
    String? customerId,
    String? deliveryAddress,
    String? currency,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceItem>? items,
    List<InvoiceMaterial>? materials,
    List<InvoiceMeasurement>? measurements,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? total,
    InvoiceStatus? status,
    String? notes,
    String? jobId,
    DateTime? paidDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      customerId: customerId ?? this.customerId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      currency: currency ?? this.currency,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      materials: materials ?? this.materials,
      measurements: measurements ?? this.measurements,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      jobId: jobId ?? this.jobId,
      paidDate: paidDate ?? this.paidDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        clientName,
        clientEmail,
        customerId,
        deliveryAddress,
        currency,
        issueDate,
        dueDate,
        items,
        materials,
        measurements,
        subtotal,
        taxRate,
        taxAmount,
        total,
        status,
        notes,
        jobId,
        paidDate,
        createdAt,
        updatedAt,
      ];
}

class InvoiceItem extends Equatable {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double amount;

  const InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  InvoiceItem copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
    double? amount,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
    );
  }

  @override
  List<Object> get props => [id, description, quantity, unitPrice, amount];
}

class InvoiceMaterial extends Equatable {
  final String? id;
  final String name;
  final String? description;
  final double quantity;
  final String unit;
  final double unitCost;

  const InvoiceMaterial({
    this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.unit,
    required this.unitCost,
  });

  @override
  List<Object?> get props => [id, name, description, quantity, unit, unitCost];
}

class InvoiceMeasurement extends Equatable {
  final String? id;
  final String label;
  final double value;
  final String unit;
  final String? notes;

  const InvoiceMeasurement({
    this.id,
    required this.label,
    required this.value,
    required this.unit,
    this.notes,
  });

  @override
  List<Object?> get props => [id, label, value, unit, notes];
}
