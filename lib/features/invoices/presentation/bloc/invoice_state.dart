part of 'invoice_bloc.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoicesLoaded extends InvoiceState {
  final List<Invoice> invoices;
  final bool hasMorePages;
  final int currentPage;

  const InvoicesLoaded({
    required this.invoices,
    this.hasMorePages = false,
    this.currentPage = 1,
  });

  @override
  List<Object> get props => [invoices, hasMorePages, currentPage];

  InvoicesLoaded copyWith({
    List<Invoice>? invoices,
    bool? hasMorePages,
    int? currentPage,
  }) {
    return InvoicesLoaded(
      invoices: invoices ?? this.invoices,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class InvoiceDetailsLoaded extends InvoiceState {
  final Invoice invoice;

  const InvoiceDetailsLoaded(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class InvoiceCreated extends InvoiceState {
  final Invoice invoice;

  const InvoiceCreated(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class InvoiceUpdated extends InvoiceState {
  final Invoice invoice;

  const InvoiceUpdated(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class InvoiceSent extends InvoiceState {
  final Invoice invoice;

  const InvoiceSent(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object> get props => [message];
}
