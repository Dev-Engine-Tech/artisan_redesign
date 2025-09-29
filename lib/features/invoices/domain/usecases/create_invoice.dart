import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';

class CreateInvoice {
  final InvoiceRepository repository;

  CreateInvoice(this.repository);

  Future<Invoice> call(Invoice invoice) async {
    return await repository.createInvoice(invoice);
  }

  Future<Invoice> execute(Invoice invoice) async {
    return await repository.createInvoice(invoice);
  }
}
