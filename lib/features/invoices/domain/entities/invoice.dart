import 'package:equatable/equatable.dart';

enum InvoiceStatus { draft, pending, validated, paid, overdue, cancelled }

class Invoice extends Equatable {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final String clientEmail;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
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
    required this.issueDate,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.status,
    this.notes,
    this.jobId,
    this.paidDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? clientName,
    String? clientEmail,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceItem>? items,
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
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
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
        issueDate,
        dueDate,
        items,
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