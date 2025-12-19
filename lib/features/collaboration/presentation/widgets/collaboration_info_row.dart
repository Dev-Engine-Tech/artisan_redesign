import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Info row widget for collaboration details
class CollaborationInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const CollaborationInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.brownHeader.withOpacity(0.6), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.brownHeader,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.brownHeader,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
