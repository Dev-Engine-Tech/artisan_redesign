import 'package:flutter/material.dart';

/// Reusable status modal for status updates with actions
///
/// Usage:
/// ```dart
/// await showStatusModal(
///   context: context,
///   title: 'Update Status',
///   message: 'Select the new status for this item',
///   options: [
///     StatusOption(label: 'Pending', value: 'pending'),
///     StatusOption(label: 'In Progress', value: 'in_progress'),
///     StatusOption(label: 'Completed', value: 'completed'),
///   ],
/// );
/// ```
Future<String?> showStatusModal({
  required BuildContext context,
  required String title,
  String? message,
  required List<StatusOption> options,
  String? currentStatus,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatusModal(
      title: title,
      message: message,
      options: options,
      currentStatus: currentStatus,
    ),
  );
}

class StatusModal extends StatelessWidget {
  const StatusModal({
    required this.title,
    this.message,
    required this.options,
    this.currentStatus,
    super.key,
  });

  final String title;
  final String? message;
  final List<StatusOption> options;
  final String? currentStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message != null) ...[
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...options.map((option) {
            final isSelected = option.value == currentStatus;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(option.value),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (option.icon != null) ...[
                        Icon(
                          option.icon,
                          color: option.color ?? theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (option.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                option.description!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Configuration for a status option
class StatusOption {
  const StatusOption({
    required this.label,
    required this.value,
    this.description,
    this.icon,
    this.color,
  });

  final String label;
  final String value;
  final String? description;
  final IconData? icon;
  final Color? color;
}
