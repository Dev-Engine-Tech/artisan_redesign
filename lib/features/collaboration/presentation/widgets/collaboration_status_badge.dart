import 'package:flutter/material.dart';
import '../../domain/entities/collaboration.dart';

/// Status badge widget for collaboration details
class CollaborationStatusBadge extends StatelessWidget {
  final CollaborationStatus status;

  const CollaborationStatusBadge({
    required this.status,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case CollaborationStatus.pending:
        color = Colors.orange;
        label = 'Pending Response';
        icon = Icons.pending_outlined;
        break;
      case CollaborationStatus.accepted:
        color = Colors.green;
        label = 'Active Collaboration';
        icon = Icons.check_circle_outline;
        break;
      case CollaborationStatus.rejected:
        color = Colors.red;
        label = 'Declined';
        icon = Icons.cancel_outlined;
        break;
      case CollaborationStatus.completed:
        color = Colors.blue;
        label = 'Completed';
        icon = Icons.task_alt;
        break;
      case CollaborationStatus.cancelled:
        color = Colors.grey;
        label = 'Cancelled';
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
