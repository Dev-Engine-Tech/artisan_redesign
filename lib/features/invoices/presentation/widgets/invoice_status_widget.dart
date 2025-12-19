import 'package:flutter/material.dart';
import '../../domain/entities/invoice.dart';
import '../../../../core/theme.dart';

/// Invoice status display widget with auto-save indicator
///
/// Shows:
/// - Current invoice status (New, Draft, Validated, Paid, etc.)
/// - Invoice number (if available)
/// - Auto-save indicator for drafts (Saving.../Saved)
class InvoiceStatusWidget extends StatelessWidget {
  final Invoice? invoice;
  final bool autoSaving;
  final bool showSavedIndicator;

  const InvoiceStatusWidget({
    this.invoice,
    this.autoSaving = false,
    this.showSavedIndicator = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String statusText = _getStatusText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statusText,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (invoice?.status == InvoiceStatus.draft &&
            (autoSaving || showSavedIndicator))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  autoSaving ? Icons.autorenew : Icons.check_circle,
                  size: 14,
                  color: autoSaving
                      ? context.primaryColor
                      : context.colorScheme.tertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  autoSaving ? 'Saving…' : 'Saved',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: autoSaving
                        ? context.primaryColor
                        : context.colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (invoice != null && invoice!.invoiceNumber.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Invoice #: ${invoice!.invoiceNumber}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.54),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  String _getStatusText() {
    if (invoice == null || (invoice?.id.isEmpty ?? true)) {
      return 'New';
    }

    switch (invoice!.status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.validated:
        return 'Validated';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }
}
