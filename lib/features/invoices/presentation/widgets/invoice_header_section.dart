import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Invoice header section containing date fields and currency selector
///
/// Displays:
/// - Invoice date picker
/// - Due date picker
/// - Currency dropdown (NGN, USD, GBP, EUR, GHS, KES)
class InvoiceHeaderSection extends StatelessWidget {
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String selectedCurrency;
  final bool readOnly;
  final ValueChanged<String>? onCurrencyChanged;
  final ValueChanged<DateTime>? onInvoiceDateChanged;
  final ValueChanged<DateTime>? onDueDateChanged;

  const InvoiceHeaderSection({
    required this.invoiceDate,
    required this.dueDate,
    required this.selectedCurrency,
    this.onCurrencyChanged,
    this.onInvoiceDateChanged,
    this.onDueDateChanged,
    this.readOnly = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectableDateField(
          context,
          'Invoice Date',
          _formatDate(invoiceDate),
          () => _selectDate(context, 'Invoice Date', invoiceDate),
        ),
        AppSpacing.spaceLG,
        _buildSelectableDateField(
          context,
          'Due Date',
          _formatDate(dueDate),
          () => _selectDate(context, 'Due Date', dueDate),
        ),
        AppSpacing.spaceLG,
        Row(
          children: [
            Expanded(
              child: Text(
                'Currency',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            AppSpacing.spaceSM,
            Flexible(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedCurrency,
                items: const [
                  DropdownMenuItem(value: 'NGN', child: Text('NGN')),
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'GHS', child: Text('GHS')),
                  DropdownMenuItem(value: 'KES', child: Text('KES')),
                ],
                onChanged: readOnly
                    ? null
                    : (v) => onCurrencyChanged?.call(v ?? 'NGN'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectableDateField(
    BuildContext context,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            AppSpacing.spaceXS,
            Icon(Icons.help_outline,
                size: 16, color: colorScheme.onSurfaceVariant),
          ],
        ),
        AppSpacing.spaceSM,
        GestureDetector(
          onTap: readOnly ? null : onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Icon(Icons.calendar_today,
                    size: 16, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(
    BuildContext context,
    String label,
    DateTime initialDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (label == 'Invoice Date') {
        onInvoiceDateChanged?.call(picked);
      } else {
        onDueDateChanged?.call(picked);
      }
    }
  }
}
