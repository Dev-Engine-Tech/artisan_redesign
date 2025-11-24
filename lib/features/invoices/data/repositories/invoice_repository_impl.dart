import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_remote_data_source.dart';
import '../models/invoice_model.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource remoteDataSource;

  InvoiceRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Invoice>> getInvoices({
    int page = 1,
    int limit = 20,
    InvoiceStatus? status,
  }) async {
    final invoices = await remoteDataSource.getInvoices(
      page: page,
      status: status?.name,
    );
    return invoices.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Invoice> getInvoiceById(String id) async {
    final invoice = await remoteDataSource.getInvoiceById(id);
    return invoice.toEntity();
  }

  @override
  Future<Invoice> createInvoice(Invoice invoice) async {
    final data = InvoiceModel.fromEntity(invoice).toJson();
    final created = await remoteDataSource.createInvoice(data);
    return created.toEntity();
  }

  @override
  Future<Invoice> updateInvoice(Invoice invoice) async {
    final data = InvoiceModel.fromEntity(invoice).toJson();
    final updated = await remoteDataSource.updateInvoice(invoice.id, data);
    return updated.toEntity();
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await remoteDataSource.deleteInvoice(id);
  }

  @override
  Future<Invoice> sendInvoice(String invoiceId) async {
    await remoteDataSource.sendInvoice(invoiceId);
    return getInvoiceById(invoiceId);
  }

  @override
  Future<Invoice> markAsPaid(String invoiceId, DateTime paidDate) async {
    final paymentData = {'paid_date': paidDate.toIso8601String()};
    final updated = await remoteDataSource.markInvoiceAsPaid(
      invoiceId,
      paymentData,
    );
    return updated.toEntity();
  }

  @override
  Future<String> generateInvoicePdf(String invoiceId) async {
    return await remoteDataSource.generateInvoicePdf(invoiceId);
  }

  @override
  Stream<List<Invoice>> watchInvoices({InvoiceStatus? status}) {
    throw UnimplementedError(
      'Stream watching is not supported for remote data source. '
      'Use getInvoices() instead and implement polling if needed.',
    );
  }
}
