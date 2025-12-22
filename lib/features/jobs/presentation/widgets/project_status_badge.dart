import 'package:flutter/material.dart';

/// Reusable status badge widget for projects
class ProjectStatusBadge extends StatelessWidget {
  final String? status;

  const ProjectStatusBadge({
    required this.status,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    Color badgeColor;
    Color textColor;
    String displayText;

    switch (status!.toLowerCase()) {
      case 'ongoing':
      case 'started':
        badgeColor =
            isDark ? Colors.blue.withValues(alpha: 0.3) : Colors.blue.shade100;
        textColor = isDark ? Colors.blue.shade200 : Colors.blue.shade800;
        displayText = 'Started';
        break;
      case 'completed':
        badgeColor = isDark
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.green.shade100;
        textColor = isDark ? Colors.green.shade200 : Colors.green.shade800;
        displayText = 'Completed';
        break;
      case 'paused':
      case 'pending':
        badgeColor = isDark
            ? Colors.orange.withValues(alpha: 0.3)
            : Colors.orange.shade100;
        textColor = isDark ? Colors.orange.shade200 : Colors.orange.shade800;
        displayText = 'Paused';
        break;
      case 'rejected':
      case 'cancelled':
        badgeColor =
            isDark ? Colors.red.withValues(alpha: 0.3) : Colors.red.shade100;
        textColor = isDark ? Colors.red.shade200 : Colors.red.shade800;
        displayText = 'Cancelled';
        break;
      default:
        badgeColor =
            isDark ? Colors.grey.withValues(alpha: 0.3) : Colors.grey.shade100;
        textColor = isDark ? Colors.grey.shade200 : Colors.grey.shade800;
        displayText = status!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
