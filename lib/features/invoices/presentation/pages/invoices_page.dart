import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../../domain/entities/invoice.dart';
import '../bloc/invoice_bloc.dart';
import 'create_invoice_page.dart';
import '../../../../core/utils/responsive.dart';

class InvoicesPage extends StatefulWidget {
  final InvoiceStatus? status;
  final String? title;

  const InvoicesPage({
    super.key,
    this.status,
    this.title,
  });

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  late final InvoiceBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<InvoiceBloc>();

    // ✅ PERFORMANCE FIX: Check state before loading
    final currentState = _bloc.state;
    if (currentState is! InvoicesLoaded) {
      _bloc.add(LoadInvoices(status: widget.status));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return 'NGN ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.validated:
        return 'Validated';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(InvoiceStatus status, BuildContext context) {
    final colorScheme = context.colorScheme;
    switch (status) {
      case InvoiceStatus.draft:
        return colorScheme.outlineVariant;
      case InvoiceStatus.pending:
        return context.primaryColor;
      case InvoiceStatus.validated:
        return context.brownHeaderColor;
      case InvoiceStatus.paid:
        return colorScheme.tertiary;
      case InvoiceStatus.overdue:
        return context.dangerColor;
      case InvoiceStatus.cancelled:
        return colorScheme.onSurfaceVariant;
    }
  }

  Widget _buildInvoiceCard(Invoice invoice, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
      ),
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: context.brownHeaderColor,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invoice.status, context).withValues(alpha: 0.1),
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: _getStatusColor(invoice.status, context)),
                  ),
                  child: Text(
                    _getStatusText(invoice.status),
                    style: TextStyle(
                      color: _getStatusColor(invoice.status, context),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.spaceSM,
            Text(
              invoice.clientName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.spaceXS,
            Text(
              'Due: ${_formatDate(invoice.dueDate)}',
              style: TextStyle(
                fontSize: 12,
                color: context.colorScheme.outlineVariant,
              ),
            ),
            AppSpacing.spaceMD,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatCurrency(invoice.total),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.brownHeaderColor,
                  ),
                ),
                Row(
                  children: [
                    if (invoice.status == InvoiceStatus.draft) ...[
                      TextAppButton(
                        text: 'Send',
                        onPressed: () {
                          // TODO: Implement send invoice
                        },
                      ),
                      AppSpacing.spaceSM,
                    ],
                    TextAppButton(
                      text: 'View',
                      onPressed: () {
                        _navigateToInvoiceDetail(context, invoice);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.lightPeachColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.title ?? 'Invoices',
          style: TextStyle(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: context.colorScheme.onSurfaceVariant),
            onPressed: () {
              _navigateToCreateInvoice(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: context.colorScheme.onSurfaceVariant),
            onPressed: () {
              // TODO: Implement more options
            },
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _bloc,
        child: BlocBuilder<InvoiceBloc, InvoiceState>(
          builder: (context, state) {
            if (state is InvoiceLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InvoiceError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: context.colorScheme.outlineVariant,
                      ),
                      AppSpacing.spaceLG,
                      Text(
                        'Error loading invoices',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      AppSpacing.spaceSM,
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.spaceLG,
                      PrimaryButton(
                        text: 'Retry',
                        onPressed: () {
                          context
                              .read<InvoiceBloc>()
                              .add(LoadInvoices(status: widget.status));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is InvoicesLoaded) {
              var invoices = state.invoices;
              // Client-side filter fallback to ensure correct bucket display
              if (widget.status != null) {
                invoices = invoices
                    .where((inv) => inv.status == widget.status)
                    .toList();
              }

              if (invoices.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: context.colorScheme.outlineVariant,
                        ),
                        AppSpacing.spaceLG,
                        Text(
                          'No invoices yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        AppSpacing.spaceSM,
                        Text(
                          'Create your first invoice to get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.spaceLG,
                        PrimaryButton(
                          text: 'Create Invoice',
                          onPressed: () {
                            _navigateToCreateInvoice(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: AppSpacing.verticalSM,
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  return _buildInvoiceCard(invoices[index], context);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.primaryColor,
        onPressed: () {
          _navigateToCreateInvoice(context);
        },
        child: Icon(Icons.add, color: context.colorScheme.onPrimary),
      ),
    );
  }

  Future<void> _navigateToInvoiceDetail(
      BuildContext context, Invoice invoice) async {
    InvoiceMode mode;
    if (invoice.status == InvoiceStatus.draft) {
      mode = InvoiceMode.edit;
    } else {
      mode = InvoiceMode.view;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateInvoicePage(
          invoice: invoice,
          mode: mode,
        ),
      ),
    );
    if (!mounted) return;
    _bloc.add(LoadInvoices(status: widget.status));
  }

  Future<void> _navigateToCreateInvoice(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateInvoicePage(
          mode: InvoiceMode.create,
        ),
      ),
    );
    if (!mounted) return;
    _bloc.add(LoadInvoices(status: widget.status));
  }
}
