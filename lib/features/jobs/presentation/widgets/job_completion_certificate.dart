import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';

class JobCompletionCertificate extends StatelessWidget {
  final Job job;

  const JobCompletionCertificate({
    required this.job,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXL,
      ),
      child: Container(
        width: double.maxFinite,
        padding: AppSpacing.paddingXXL,
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusXL,
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: AppColors.orange,
                  size: 24,
                ),
                AppSpacing.spaceSM,
                const Text(
                  'Completion Certificate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownHeader,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMD,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.spaceXL,

            // Certificate Content
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade50,
                    Colors.amber.shade50,
                  ],
                ),
                borderRadius: AppRadius.radiusLG,
                border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.2), width: 2),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: AppSpacing.paddingLG,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: AppRadius.radiusMD,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 28,
                        ),
                        AppSpacing.spaceSM,
                        Text(
                          'PROJECT COMPLETED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.spaceXXL,

                  // Certificate Body
                  Text(
                    'This certifies that',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  AppSpacing.spaceSM,

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.radiusMD,
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: const Text(
                      'ARTISAN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownHeader,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  AppSpacing.spaceLG,

                  Text(
                    'has successfully completed the project',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  AppSpacing.spaceSM,

                  Container(
                    padding: AppSpacing.paddingMD,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.radiusMD,
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: Column(
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownHeader,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.spaceXS,
                        Text(
                          job.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.spaceLG,

                  // Project Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCertificateDetail(
                        'Duration',
                        job.duration,
                        Icons.schedule,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.softBorder,
                      ),
                      _buildCertificateDetail(
                        'Value',
                        'NGN ${_formatAmount(job.agreement?.amount ?? job.minBudget.toDouble())}',
                        Icons.attach_money,
                      ),
                      if (job.rating != null) ...[
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.softBorder,
                        ),
                        _buildCertificateDetail(
                          'Rating',
                          '${job.rating!.toStringAsFixed(1)}★',
                          Icons.star,
                        ),
                      ],
                    ],
                  ),

                  AppSpacing.spaceXL,

                  // Completion Date
                  if (job.completedDate != null) ...[
                    Text(
                      'Completed on ${_formatDate(job.completedDate!)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  AppSpacing.spaceLG,

                  // Verification Code
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: Text(
                      'Verification Code: AC${job.id.toUpperCase().substring(0, 8)}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.spaceXXL,

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedAppButton(
                    text: 'Download',
                    onPressed: () => _downloadCertificate(context),
                  ),
                ),
                AppSpacing.spaceMD,
                Expanded(
                  child: PrimaryButton(
                    text: 'Share',
                    onPressed: () => _shareCertificate(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.orange,
        ),
        AppSpacing.spaceXS,
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.brownHeader,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _downloadCertificate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Certificate download started'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  void _shareCertificate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Certificate shared successfully'),
        backgroundColor: Colors.blue,
      ),
    );
    Navigator.of(context).pop();
  }
}
