import 'package:flutter/material.dart';

/// Reusable confirmation modal for yes/no decisions
///
/// Usage:
/// ```dart
/// final confirmed = await showConfirmationModal(
///   context: context,
///   title: 'Delete Item',
///   message: 'Are you sure you want to delete this item?',
///   confirmText: 'Delete',
///   cancelText: 'Cancel',
///   isDestructive: true,
/// );
///
/// if (confirmed == true) {
///   // User confirmed
/// }
/// ```
Future<bool?> showConfirmationModal({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
  Widget? icon,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => ConfirmationModal(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
      icon: icon,
    ),
  );
}

class ConfirmationModal extends StatelessWidget {
  const ConfirmationModal({
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.icon,
    super.key,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
