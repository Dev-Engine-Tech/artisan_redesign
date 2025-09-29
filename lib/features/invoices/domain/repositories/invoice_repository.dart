import '../entities/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getInvoices({
    int page = 1,
    int limit = 20,
    InvoiceStatus? status,
  });

  Future<Invoice> getInvoiceById(String id);

  Future<Invoice> createInvoice(Invoice invoice);

  Future<Invoice> updateInvoice(Invoice invoice);

  Future<void> deleteInvoice(String id);

  Future<Invoice> sendInvoice(String invoiceId);

  Future<Invoice> markAsPaid(String invoiceId, DateTime paidDate);

  Future<String> generateInvoicePdf(String invoiceId);

  Stream<List<Invoice>> watchInvoices({
    InvoiceStatus? status,
  });
}