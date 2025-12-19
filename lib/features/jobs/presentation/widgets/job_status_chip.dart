import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Status chip widget for job application status
class JobStatusChip extends StatelessWidget {
  final String status;

  const JobStatusChip({
    required this.status,
    super.key,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Review Agreement':
        return Colors.orange;
      case 'Change request sent':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
