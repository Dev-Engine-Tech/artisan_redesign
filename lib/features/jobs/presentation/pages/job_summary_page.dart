import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import '../../../../core/utils/responsive.dart';
import 'package:artisans_circle/core/utils/currency.dart';

class JobSummaryPage extends StatelessWidget {
  final Job job;

  const JobSummaryPage({required this.job, super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Review Agreement':
        return Colors.orange;
      case 'Change request sent':
        return Colors.blue;
      case 'Application sent':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = job.applicationStatus;
    final statusColor = _statusColor(statusText);

    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.softPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text('Project Summary',
            style: TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: context.maxContentWidth),
            child: ListView(
              padding: context.responsivePadding,
              children: [
                // Header card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: AppColors.softBorder),
                  ),
                  padding: context.responsivePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(job.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(job.category,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.black45)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: AppRadius.radiusLG,
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.4)),
                            ),
                            child: Text(statusText,
                                style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Budget: ${Currency.formatNgn(job.minBudget)} - ${Currency.formatNgn(job.maxBudget)}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('Duration: ${job.duration}',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),

                AppSpacing.spaceLG,

                // Materials
                if (job.materials.isNotEmpty) ...[
                  Text('Materials',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  AppSpacing.spaceSM,
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: AppRadius.radiusLG,
                      border: Border.all(color: AppColors.subtleBorder),
                    ),
                    child: Column(
                      children: job.materials.map((m) {
                        return ListTile(
                          title: Text(m.description),
                          subtitle: Text('Qty: ${m.quantity ?? 1}'),
                          trailing: Text(Currency.formatNgn(m.price ?? 0)),
                        );
                      }).toList(),
                    ),
                  ),
                  AppSpacing.spaceLG,
                ],

                // Agreement block
                if (job.agreement != null) ...[
                  Text('Agreement',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  AppSpacing.spaceSM,
                  Container(
                    padding: context.responsivePadding,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: AppRadius.radiusLG,
                      border: Border.all(color: AppColors.subtleBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${job.agreement!.status}',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Text(
                            'Agreed Payment: ${Currency.formatNgn(job.agreement!.agreedPayment)}'),
                        if (job.agreement!.comment.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Comment: ${job.agreement!.comment}'),
                        ]
                      ],
                    ),
                  ),
                  AppSpacing.spaceLG,
                ],

                // Client review (if available)
                if ((job.clientReview ?? '').isNotEmpty) ...[
                  Text('Client Review',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  AppSpacing.spaceSM,
                  Container(
                    padding: context.responsivePadding,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: AppRadius.radiusLG,
                      border: Border.all(color: AppColors.subtleBorder),
                    ),
                    child: Text(job.clientReview!),
                  ),
                  AppSpacing.spaceLG,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
