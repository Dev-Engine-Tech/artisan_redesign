import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Agreement row widget for order details
class OrderAgreementRow extends StatelessWidget {
  final String label;
  final String value;

  const OrderAgreementRow({
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.brownHeader,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.brownHeader,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
