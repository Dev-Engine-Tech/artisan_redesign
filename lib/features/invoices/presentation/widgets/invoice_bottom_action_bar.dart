import 'package:flutter/material.dart';
import '../../domain/entities/invoice.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';
import '../../../../core/utils/responsive.dart';

/// Bottom action bar for invoice operations
///
/// Displays contextual buttons based on invoice status:
/// - Share (always available)
/// - Create Job (for draft and validated invoices)
/// - Update (for validated invoices with unsaved changes)
/// - Save/Confirm/Paid (main action based on status)
class InvoiceBottomActionBar extends StatelessWidget {
  final Invoice? invoice;
  final bool hasUnsavedChanges;
  final VoidCallback onShare;
  final VoidCallback onCreateJob;
  final VoidCallback? onUpdate;
  final VoidCallback? onSave;
  final VoidCallback? onConfirm;
  final VoidCallback? onPaid;

  const InvoiceBottomActionBar({
    required this.invoice,
    required this.hasUnsavedChanges,
    required this.onShare,
    required this.onCreateJob,
    this.onUpdate,
    this.onSave,
    this.onConfirm,
    this.onPaid,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus =
        (invoice == null || invoice!.id.isEmpty) ? null : invoice!.status;

    List<Widget> buttons = [];

    // Always show Share button
    buttons.add(
      Expanded(
        child: OutlinedAppButton(
          text: 'Share',
          onPressed: onShare,
        ),
      ),
    );

    buttons.add(AppSpacing.spaceSM);

    // Show Create Job button for draft and validated invoices
    if (currentStatus == null ||
        currentStatus == InvoiceStatus.draft ||
        currentStatus == InvoiceStatus.validated) {
      buttons.add(
        Expanded(
          child: OutlinedAppButton(
            text: 'Create Job',
            onPressed: onCreateJob,
          ),
        ),
      );

      buttons.add(AppSpacing.spaceSM);
    }

    // Show Update button when validated (persist edited lines)
    if (currentStatus == InvoiceStatus.validated) {
      buttons.add(
        Expanded(
          child: OutlinedAppButton(
            text: hasUnsavedChanges ? 'Update •' : 'Update',
            onPressed: onUpdate,
          ),
        ),
      );

      buttons.add(AppSpacing.spaceSM);
    }

    // Add main action button (Save → Confirm → Paid)
    final mainAction = _getMainAction(currentStatus);
    buttons.add(
      Expanded(
        child: PrimaryButton(
          text: mainAction.text,
          onPressed: mainAction.onPressed,
        ),
      ),
    );

    return Builder(
      builder: (context) => Container(
        padding: context.responsivePadding,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: buttons,
          ),
        ),
      ),
    );
  }

  _MainAction _getMainAction(InvoiceStatus? currentStatus) {
    if (currentStatus == null) {
      // New/unsaved: Save
      return _MainAction('Save', onSave);
    } else if (currentStatus == InvoiceStatus.draft) {
      // Draft: Confirm
      return _MainAction('Confirm', onConfirm);
    } else if (currentStatus == InvoiceStatus.validated) {
      // Validated: Paid
      return _MainAction('Paid', onPaid);
    } else if (currentStatus == InvoiceStatus.paid) {
      // Paid: show disabled Paid
      return _MainAction('Paid', null);
    } else {
      // Fallback: allow confirm
      return _MainAction('Confirm', onConfirm);
    }
  }
}

class _MainAction {
  final String text;
  final VoidCallback? onPressed;

  _MainAction(this.text, this.onPressed);
}
