import 'package:equatable/equatable.dart';
import 'invoice_model.dart';

/// Dashboard statistics for invoices and earnings
class InvoiceDashboardModel extends Equatable {
  final double earningsBalance;
  final double totalOutstanding;
  final double paidThisMonth;
  final int draftCount;
  final int validatedCount;
  final int paidCount;
  final int customerCount;
  final List<InvoiceModel> recentInvoices;
  final List<CustomerSummary> frequentCustomers;

  const InvoiceDashboardModel({
    required this.earningsBalance,
    required this.totalOutstanding,
    required this.paidThisMonth,
    required this.draftCount,
    required this.validatedCount,
    required this.paidCount,
    required this.customerCount,
    required this.recentInvoices,
    required this.frequentCustomers,
  });

  factory InvoiceDashboardModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDashboardModel(
      earningsBalance: (json['earnings_balance'] ?? 0).toDouble(),
      totalOutstanding: (json['total_outstanding'] ?? 0).toDouble(),
      paidThisMonth: (json['paid_this_month'] ?? 0).toDouble(),
      draftCount: json['draft_count'] ?? 0,
      validatedCount: json['validated_count'] ?? 0,
      paidCount: json['paid_count'] ?? 0,
      customerCount: json['customer_count'] ?? 0,
      recentInvoices: (json['recent_invoices'] as List?)
              ?.map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      frequentCustomers: (json['frequent_customers'] as List?)
              ?.map((e) => CustomerSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earnings_balance': earningsBalance,
      'total_outstanding': totalOutstanding,
      'paid_this_month': paidThisMonth,
      'draft_count': draftCount,
      'validated_count': validatedCount,
      'paid_count': paidCount,
      'customer_count': customerCount,
      'recent_invoices': recentInvoices.map((i) => i.toJson()).toList(),
      'frequent_customers': frequentCustomers.map((c) => c.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        earningsBalance,
        totalOutstanding,
        paidThisMonth,
        draftCount,
        validatedCount,
        paidCount,
        customerCount,
        recentInvoices,
        frequentCustomers,
      ];
}

/// Summary of customer invoice statistics
class CustomerSummary extends Equatable {
  final String customerId;
  final String customerName;
  final String customerEmail;
  final int invoiceCount;

  const CustomerSummary({
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.invoiceCount,
  });

  factory CustomerSummary.fromJson(Map<String, dynamic> json) {
    return CustomerSummary(
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      invoiceCount: json['invoice_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'invoice_count': invoiceCount,
    };
  }

  @override
  List<Object?> get props => [
        customerId,
        customerName,
        customerEmail,
        invoiceCount,
      ];
}
