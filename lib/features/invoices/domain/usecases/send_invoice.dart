import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';

class SendInvoice {
  final InvoiceRepository repository;

  SendInvoice(this.repository);

  Future<Invoice> call(String invoiceId) async {
    return await repository.sendInvoice(invoiceId);
  }

  Future<Invoice> execute(String invoiceId) async {
    return await repository.sendInvoice(invoiceId);
  }
}
