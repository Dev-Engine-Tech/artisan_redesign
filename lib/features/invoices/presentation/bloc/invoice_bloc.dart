import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/usecases/get_invoices.dart';
import '../../domain/usecases/create_invoice.dart' as usecase;
import '../../domain/usecases/send_invoice.dart' as usecase;

part 'invoice_event.dart';
part 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final GetInvoices getInvoices;
  final usecase.CreateInvoice createInvoice;
  final usecase.SendInvoice sendInvoice;
  final InvoiceRepository repository;

  InvoiceBloc({
    required this.getInvoices,
    required this.createInvoice,
    required this.sendInvoice,
    required this.repository,
  }) : super(InvoiceInitial()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<LoadInvoiceDetails>(_onLoadInvoiceDetails);
    on<CreateInvoiceEvent>(_onCreateInvoice);
    on<UpdateInvoiceEvent>(_onUpdateInvoice);
    on<SendInvoiceEvent>(_onSendInvoice);
    on<MarkInvoiceAsPaid>(_onMarkInvoiceAsPaid);
    on<DeleteInvoice>(_onDeleteInvoice);
  }

  Future<void> _onLoadInvoices(
    LoadInvoices event,
    Emitter<InvoiceState> emit,
  ) async {
    try {
      emit(InvoiceLoading());
      final invoices = await getInvoices(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );

      emit(InvoicesLoaded(
        invoices: invoices,
        hasMorePages: invoices.length >= event.limit,
        currentPage: event.page,
      ));
    } catch (e) {
      emit(InvoiceError('Failed to load invoices: ${e.toString()}'));
    }
  }

  Future<void> _onLoadInvoiceDetails(
    LoadInvoiceDetails event,
    Emitter<InvoiceState> emit,
  ) async {
    try {
      emit(InvoiceLoading());
      final invoice = await repository.getInvoiceById(event.invoiceId);
      emit(InvoiceDetailsLoaded(invoice));
    } catch (e) {
      emit(InvoiceError('Failed to load invoice details: ${e.toString()}'));
    }
  }

  Future<void> _onCreateInvoice(
    CreateInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    try {
      emit(InvoiceLoading());
      final invoice = await createInvoice.call(event.invoice);
      emit(InvoiceCreated(invoice));
    } catch (e) {
      emit(InvoiceError('Failed to create invoice: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateInvoice(
    UpdateInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    try {
      emit(InvoiceLoading());
      final invoice = await repository.updateInvoice(event.invoice);
      emit(InvoiceUpdated(invoice));
    } catch (e) {
      emit(InvoiceError('Failed to update invoice: ${e.toString()}'));
    }
  }

  Future<void> _onSendInvoice(
    SendInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    try {
      emit(InvoiceLoading());
      final invoice = await sendInvoice.call(event.invoiceId);
      emit(InvoiceSent(invoice));
    } catch (e) {
      emit(InvoiceError('Failed to send invoice: ${e.toString()}'));
    }
  }

  Future<void> _onMarkInvoiceAsPaid(
    MarkInvoiceAsPaid event,
    Emitter<InvoiceState> emit,
  ) async {
    try {
      emit(InvoiceLoading());
      final invoice =
          await repository.markAsPaid(event.invoiceId, event.paidDate);
      emit(InvoiceUpdated(invoice));
    } catch (e) {
      emit(InvoiceError('Failed to mark invoice as paid: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteInvoice(
    DeleteInvoice event,
    Emitter<InvoiceState> emit,
  ) async {
    try {
      emit(InvoiceLoading());
      await repository.deleteInvoice(event.invoiceId);

      // Reload the invoices list after deletion
      if (state is InvoicesLoaded) {
        final currentState = state as InvoicesLoaded;
        add(LoadInvoices(
          page: currentState.currentPage,
          limit: 20,
        ));
      } else {
        add(const LoadInvoices());
      }
    } catch (e) {
      emit(InvoiceError('Failed to delete invoice: ${e.toString()}'));
    }
  }
}
