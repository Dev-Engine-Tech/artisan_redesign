import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/responsive.dart';

/// Earnings balance card with mini chart for invoice menu
class InvoiceEarningsCard extends StatelessWidget {
  final double earningsBalance;
  final bool loading;

  const InvoiceEarningsCard({
    required this.earningsBalance,
    required this.loading,
    super.key,
  });

  Widget _buildChartBar(double height) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.primaryColor,
            context.primaryColor.withValues(alpha: 0.8)
          ],
        ),
        borderRadius: AppRadius.radiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings balance',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.spaceXS,
          Text(
            loading
                ? 'Loading...'
                : 'NGN ${earningsBalance.toStringAsFixed(0)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.spaceMD,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildChartBar(20),
              const SizedBox(width: 3),
              _buildChartBar(30),
              const SizedBox(width: 3),
              _buildChartBar(18),
              const SizedBox(width: 3),
              _buildChartBar(35),
              const SizedBox(width: 3),
              _buildChartBar(25),
              const SizedBox(width: 3),
              _buildChartBar(40),
              const SizedBox(width: 3),
              _buildChartBar(32),
              const SizedBox(width: 3),
              _buildChartBar(22),
              const SizedBox(width: 3),
              _buildChartBar(28),
            ],
          ),
        ],
      ),
    );
  }
}
