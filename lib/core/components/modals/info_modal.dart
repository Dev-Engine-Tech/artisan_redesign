import 'package:flutter/material.dart';

/// Reusable info modal for displaying information
///
/// Usage:
/// ```dart
/// await showInfoModal(
///   context: context,
///   title: 'Success',
///   content: Text('Your action was completed successfully'),
///   icon: Icon(Icons.check_circle, color: Colors.green, size: 48),
/// );
/// ```
Future<void> showInfoModal({
  required BuildContext context,
  required String title,
  required Widget content,
  Widget? icon,
  String buttonText = 'OK',
}) {
  return showDialog(
    context: context,
    builder: (ctx) => InfoModal(
      title: title,
      content: content,
      icon: icon,
      buttonText: buttonText,
    ),
  );
}

class InfoModal extends StatelessWidget {
  const InfoModal({
    required this.title,
    required this.content,
    this.icon,
    this.buttonText = 'OK',
    super.key,
  });

  final String title;
  final Widget content;
  final Widget? icon;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(height: 16),
          ],
          content,
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(buttonText),
        ),
      ],
    );
  }
}
