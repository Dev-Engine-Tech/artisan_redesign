import 'dart:async';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../models/invoice_model.dart';

class InvoiceRepositoryFake implements InvoiceRepository {
  final List<InvoiceModel> _invoices = [];
  final StreamController<List<Invoice>> _streamController =
      StreamController.broadcast();

  InvoiceRepositoryFake() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    final sampleInvoices = [
      InvoiceModel(
        id: '1',
        invoiceNumber: 'INV-001',
        clientName: 'John Doe',
        clientEmail: 'john.doe@example.com',
        issueDate: now.subtract(const Duration(days: 7)),
        dueDate: now.add(const Duration(days: 23)),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Home Electrical Work',
            quantity: 1,
            unitPrice: 250000,
            amount: 250000,
          ),
          InvoiceItemModel(
            id: '2',
            description: 'Materials and Components',
            quantity: 1,
            unitPrice: 75000,
            amount: 75000,
          ),
        ],
        subtotal: 325000,
        taxRate: 0.075,
        taxAmount: 24375,
        total: 349375,
        status: InvoiceStatus.validated,
        notes: 'Payment due within 30 days',
        jobId: 'job_123',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      InvoiceModel(
        id: '2',
        invoiceNumber: 'INV-002',
        clientName: 'Jane Smith',
        clientEmail: 'jane.smith@example.com',
        issueDate: now.subtract(const Duration(days: 3)),
        dueDate: now.add(const Duration(days: 27)),
        items: const [
          InvoiceItemModel(
            id: '3',
            description: 'Furniture Design and Creation',
            quantity: 2,
            unitPrice: 150000,
            amount: 300000,
          ),
        ],
        subtotal: 300000,
        taxRate: 0.075,
        taxAmount: 22500,
        total: 322500,
        status: InvoiceStatus.draft,
        notes: 'Custom furniture pieces as discussed',
        jobId: 'job_456',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      InvoiceModel(
        id: '3',
        invoiceNumber: 'INV-003',
        clientName: 'Mike Johnson',
        clientEmail: 'mike.johnson@example.com',
        issueDate: now.subtract(const Duration(days: 45)),
        dueDate: now.subtract(const Duration(days: 15)),
        items: const [
          InvoiceItemModel(
            id: '4',
            description: 'Plumbing Installation',
            quantity: 1,
            unitPrice: 180000,
            amount: 180000,
          ),
        ],
        subtotal: 180000,
        taxRate: 0.075,
        taxAmount: 13500,
        total: 193500,
        status: InvoiceStatus.paid,
        notes: 'Paid via bank transfer',
        jobId: 'job_789',
        paidDate: now.subtract(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];

    _invoices.addAll(sampleInvoices);
    _streamController.add(_invoices.map((e) => e.toEntity()).toList());
  }

  @override
  Future<List<Invoice>> getInvoices({
    int page = 1,
    int limit = 20,
    InvoiceStatus? status,
  }) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay

    var filteredInvoices = _invoices.where((invoice) {
      if (status != null) {
        return invoice.status == status;
      }
      return true;
    }).toList();

    // Sort by creation date (newest first)
    filteredInvoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;

    if (startIndex >= filteredInvoices.length) {
      return [];
    }

    final paginatedInvoices = filteredInvoices.sublist(
      startIndex,
      endIndex > filteredInvoices.length ? filteredInvoices.length : endIndex,
    );

    return paginatedInvoices.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Invoice> getInvoiceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final invoice = _invoices.firstWhere(
      (invoice) => invoice.id == id,
      orElse: () => throw Exception('Invoice not found'),
    );

    return invoice.toEntity();
  }

  @override
  Future<Invoice> createInvoice(Invoice invoice) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newInvoice = InvoiceModel.fromEntity(invoice.copyWith(
      id: 'INV_${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: 'INV-${(_invoices.length + 1).toString().padLeft(3, '0')}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    _invoices.add(newInvoice);
    _streamController.add(_invoices.map((e) => e.toEntity()).toList());

    return newInvoice.toEntity();
  }

  @override
  Future<Invoice> updateInvoice(Invoice invoice) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _invoices.indexWhere((inv) => inv.id == invoice.id);
    if (index == -1) {
      throw Exception('Invoice not found');
    }

    final updatedInvoice = InvoiceModel.fromEntity(invoice.copyWith(
      updatedAt: DateTime.now(),
    ));

    _invoices[index] = updatedInvoice;
    _streamController.add(_invoices.map((e) => e.toEntity()).toList());

    return updatedInvoice.toEntity();
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _invoices.removeWhere((invoice) => invoice.id == id);
    _streamController.add(_invoices.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Invoice> sendInvoice(String invoiceId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final invoice = await getInvoiceById(invoiceId);
    final updatedInvoice = invoice.copyWith(
      status: InvoiceStatus.validated,
      updatedAt: DateTime.now(),
    );

    return await updateInvoice(updatedInvoice);
  }

  @override
  Future<Invoice> markAsPaid(String invoiceId, DateTime paidDate) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final invoice = await getInvoiceById(invoiceId);
    final updatedInvoice = invoice.copyWith(
      status: InvoiceStatus.paid,
      paidDate: paidDate,
      updatedAt: DateTime.now(),
    );

    return await updateInvoice(updatedInvoice);
  }

  @override
  Future<String> generateInvoicePdf(String invoiceId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real implementation, this would generate a PDF and return the file path or URL
    return 'https://example.com/invoices/$invoiceId.pdf';
  }

  @override
  Stream<List<Invoice>> watchInvoices({InvoiceStatus? status}) {
    return _streamController.stream.map((invoices) {
      if (status != null) {
        return invoices.where((invoice) => invoice.status == status).toList();
      }
      return invoices;
    });
  }

  void dispose() {
    _streamController.close();
  }
}
