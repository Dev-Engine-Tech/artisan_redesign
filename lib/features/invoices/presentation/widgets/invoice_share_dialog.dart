import 'package:flutter/material.dart';
import '../../../../core/components/components.dart';

/// Invoice share options dialog
///
/// Presents three sharing options:
/// - Generate Link and Share
/// - Download PDF and Share (File)
/// - Send Email to Customer
class InvoiceShareDialog extends StatelessWidget {
  final VoidCallback onShareLink;
  final VoidCallback onShareFile;
  final VoidCallback onSendEmail;

  const InvoiceShareDialog({
    required this.onShareLink,
    required this.onShareFile,
    required this.onSendEmail,
    super.key,
  });

  /// Shows the share dialog as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onShareLink,
    required VoidCallback onShareFile,
    required VoidCallback onSendEmail,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => InvoiceShareDialog(
        onShareLink: onShareLink,
        onShareFile: onShareFile,
        onSendEmail: onSendEmail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Share Invoice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              text: 'Generate Link and Share',
              height: 48,
              onPressed: () {
                Navigator.of(context).pop();
                onShareLink();
              },
            ),
            const SizedBox(height: 10),
            OutlinedAppButton(
              text: 'Download PDF and Share (File)',
              height: 48,
              onPressed: () {
                Navigator.of(context).pop();
                onShareFile();
              },
            ),
            const SizedBox(height: 10),
            TextAppButton(
              text: 'Send Email to Customer',
              onPressed: () {
                Navigator.of(context).pop();
                onSendEmail();
              },
            ),
          ],
        ),
      ),
    );
  }
}
