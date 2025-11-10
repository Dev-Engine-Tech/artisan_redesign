import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/application_card.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/agreement_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/change_request_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_details_page.dart';

class ApplicationsList extends StatefulWidget {
  final List<Job> applications;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;
  final Function(Job)? onApplicationUpdate;

  const ApplicationsList({
    required this.applications,
    super.key,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onApplicationUpdate,
  });

  @override
  State<ApplicationsList> createState() => _ApplicationsListState();
}

class _ApplicationsListState extends State<ApplicationsList> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            AppSpacing.spaceLG,
            Text(
              'Error loading applications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            AppSpacing.spaceSM,
            Text(
              widget.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 14,
              ),
            ),
            AppSpacing.spaceXXL,
            PrimaryButton(
              text: 'Retry',
              onPressed: widget.onRefresh,
            ),
          ],
        ),
      );
    }

    if (widget.applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            AppSpacing.spaceLG,
            Text(
              'No applications found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            AppSpacing.spaceSM,
            Text(
              'Start applying to jobs to see them here',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh?.call();
      },
      child: ListView.builder(
        padding: AppSpacing.paddingLG,
        itemCount: widget.applications.length,
        itemBuilder: (context, index) {
          final application = widget.applications[index];
          return ApplicationCard(
            job: application,
            onTap: () => _handleViewDetails(application),
            onAgreementTap: () => _handleAcceptAgreement(application),
            onChangeRequestTap: () => _handleRequestChange(application),
          );
        },
      ),
    );
  }

  void _handleAcceptAgreement(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgreementPage(job: job),
      ),
    );
  }

  void _handleRequestChange(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeRequestPage(job: job),
      ),
    );
  }

  void _handleViewDetails(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsPage(job: job),
      ),
    );
  }
}
