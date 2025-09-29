import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';

class GetInvoices {
  final InvoiceRepository repository;

  GetInvoices(this.repository);

  Future<List<Invoice>> call({
    int page = 1,
    int limit = 20,
    InvoiceStatus? status,
  }) async {
    return await repository.getInvoices(
      page: page,
      limit: limit,
      status: status,
    );
  }
}