import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Badge widget for order details
class OrderBadge extends StatelessWidget {
  final String text;

  const OrderBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.only(right: 8, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.softPeach,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.brownHeader),
      ),
    );
  }
}
