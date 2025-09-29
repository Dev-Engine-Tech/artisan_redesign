part of 'invoice_bloc.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvoices extends InvoiceEvent {
  final int page;
  final int limit;
  final InvoiceStatus? status;

  const LoadInvoices({
    this.page = 1,
    this.limit = 20,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, status];
}

class LoadInvoiceDetails extends InvoiceEvent {
  final String invoiceId;

  const LoadInvoiceDetails(this.invoiceId);

  @override
  List<Object> get props => [invoiceId];
}

class CreateInvoiceEvent extends InvoiceEvent {
  final Invoice invoice;

  const CreateInvoiceEvent(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class UpdateInvoiceEvent extends InvoiceEvent {
  final Invoice invoice;

  const UpdateInvoiceEvent(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class SendInvoiceEvent extends InvoiceEvent {
  final String invoiceId;

  const SendInvoiceEvent(this.invoiceId);

  @override
  List<Object> get props => [invoiceId];
}

class MarkInvoiceAsPaid extends InvoiceEvent {
  final String invoiceId;
  final DateTime paidDate;

  const MarkInvoiceAsPaid(this.invoiceId, this.paidDate);

  @override
  List<Object> get props => [invoiceId, paidDate];
}

class DeleteInvoice extends InvoiceEvent {
  final String invoiceId;

  const DeleteInvoice(this.invoiceId);

  @override
  List<Object> get props => [invoiceId];
}
