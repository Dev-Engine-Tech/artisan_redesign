import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/invoice_form_cubit.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/responsive.dart';

/// Invoice totals display section
///
/// Shows:
/// - Subtotal (Invoice Lines)
/// - Subtotal (Materials)
/// - Grand Total
///
/// Automatically updates based on InvoiceFormCubit state
class InvoiceTotalsSection extends StatelessWidget {
  const InvoiceTotalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
      builder: (context, state) {
        final cubit = context.read<InvoiceFormCubit>();
        return Container(
          width: double.infinity,
          padding: context.responsivePadding,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: AppRadius.radiusMD,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTotalRow(
                'Subtotal (Invoice):',
                'NGN ${cubit.invoiceLinesTotal.toStringAsFixed(2)}',
              ),
              _buildTotalRow(
                'Subtotal (Materials):',
                'NGN ${cubit.materialsTotal.toStringAsFixed(2)}',
              ),
              const Divider(),
              _buildTotalRow(
                'Total:',
                'NGN ${cubit.grandTotal.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalRow(
    String label,
    String amount, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
