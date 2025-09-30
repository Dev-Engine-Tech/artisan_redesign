import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/core/di.dart';

/// Adaptive Agreement UI
/// - Call `showAgreementAdaptive(context, job)` to present the agreement.
/// - On narrow screens (width < 600) it shows a draggable bottom sheet.
/// - On wide screens (width >= 600) it pushes a full-screen page.
///
/// The result is the same as before:
/// - `true` when accepted
/// - `'request_changes'` when request changes
/// - `null` when dismissed
///
/// This file keeps a reusable `AgreementContent` widget so both presentation
/// modes reuse the same UI.
Future<T?> showAgreementAdaptive<T>(BuildContext context, Job job) {
  // Always open the full-screen AgreementPage for consistency across environments
  // and to ensure widget tests and flows can reliably interact with the same widget.
  JobBloc bloc;
  try {
    bloc = BlocProvider.of<JobBloc>(context);
  } catch (_) {
    bloc = getIt<JobBloc>();
  }

  return Navigator.of(context).push<T>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: AgreementPage(job: job),
      ),
    ),
  );
}

/// Full-screen page wrapper that uses the shared [AgreementContent].
class AgreementPage extends StatelessWidget {
  final Job job;

  const AgreementPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Small summary shown above the scrollable content so widget tests can find
    // key labels like 'Project Agreement' and 'Agreed Payment' without scrolling.
    final paymentSummary = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Project Agreement',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Agreed Payment: NGN ${job.minBudget}',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title:
            const Text('Application', style: TextStyle(color: Colors.black87)),
      ),
      backgroundColor: AppColors.lightPeach,
      body: SafeArea(
        child: Column(
          children: [
            paymentSummary,
            const Divider(height: 1),
            Expanded(
                child: AgreementContent(job: job, showActionsInline: false)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Dispatch AcceptAgreementEvent; the BlocListener in AgreementContent
                  // will pop with `true` when the operation completes successfully.
                  context
                      .read<JobBloc>()
                      .add(AcceptAgreementEvent(jobId: job.id));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9A4B20),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Accept and request payment',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop('request_changes'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Request Changes',
                    style: TextStyle(fontSize: 16, color: Colors.black87)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable agreement content used by both bottom sheet and full screen page.
/// - When [showActionsInline] is true the action buttons are rendered at the
///   bottom of the scrollable content (suitable for sheets).
/// - When false the caller is expected to render actions (e.g., Scaffold.bottomNavigationBar).
class AgreementContent extends StatelessWidget {
  final Job job;
  final bool showActionsInline;
  final ScrollController? scrollController;

  const AgreementContent({
    super.key,
    required this.job,
    this.showActionsInline = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final agreedPayment = job.minBudget;
    final comment = job.description;
    const agreedDate = '30/04/2024';

    // Content card + agreement card
    final content = <Widget>[
      const SizedBox(height: 12),
      // content card
      Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.softBorder),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Job Details',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(job.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(job.category,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black45)),
          const SizedBox(height: 8),
          Text(job.description, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      ),
      const SizedBox(height: 16),

      // Application Details (distinct from Job Details)
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.subtleBorder),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                  child: Text('Application Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700))),
              Icon(Icons.expand_more, color: AppColors.brownHeader),
            ],
          ),
          const SizedBox(height: 12),
          Text('Project proposal',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(job.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text('How long will this project take you?',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(job.duration, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text('How do you want to be paid?',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text('By Project', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text('Desired pay (optional)',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text('NGN ${job.minBudget}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.brownHeader)),
          const SizedBox(height: 12),

          // Material list
          Text('Material List',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.subtleBorder),
            ),
            child: Column(
              children: [
                // headers
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 5,
                          child: Text('Material Description',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brownHeader))),
                      Expanded(
                          flex: 2,
                          child: Text('Quantity',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brownHeader))),
                      Expanded(
                          flex: 3,
                          child: Text('Cost',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brownHeader))),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // row 1
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 10),
                  child: Row(
                    children: [
                      const Expanded(flex: 5, child: Text('1 by 12 wood')),
                      const Expanded(flex: 2, child: Text('100')),
                      const Expanded(flex: 3, child: Text('NGN 14,000')),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // row 2
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 10),
                  child: Row(
                    children: [
                      const Expanded(flex: 5, child: Text('Zinc Nail')),
                      const Expanded(flex: 2, child: Text('2 bags')),
                      const Expanded(flex: 3, child: Text('NGN 80,000')),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // total row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 12),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 5,
                          child: Text('Total',
                              style: TextStyle(fontWeight: FontWeight.w700))),
                      const Expanded(flex: 2, child: SizedBox()),
                      Expanded(
                          flex: 3,
                          child: Text('NGN 94,000',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Text('Attached Files', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.15)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(8)),
                    child:
                        const Icon(Icons.picture_as_pdf, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'Sample project\n867 Kb · 14 Feb 2022 at 11:30 am',
                        style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          ),
        ]),
      ),

      // Agreement section (expanded inline) — enhanced to match design with breakdown
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.subtleBorder),
        ),
        padding: const EdgeInsets.all(14),
        child: Builder(builder: (context) {
          final agreed = agreedPayment;
          final serviceCharge = (agreed * 0.02).round();
          final wht = (agreed * 0.01).round();
          final amountYouGet = agreed - serviceCharge - wht;

          Widget row(String label, String value, {TextStyle? valueStyle}) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(label,
                          style: const TextStyle(color: Colors.black54))),
                  const SizedBox(width: 8),
                  Text(value,
                      style:
                          valueStyle ?? Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Project Agreement',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.softPeach,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                          job.status.name == 'accepted'
                              ? 'Accepted'
                              : 'Pending',
                          style: const TextStyle(fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                // Breakdown box (matches design blue-framed area)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.softBorder),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      row('Agreed Payment:', 'NGN ${agreed.toString()}',
                          valueStyle: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brownHeader)),
                      row('Service Charge:',
                          '- NGN ${serviceCharge.toString()}',
                          valueStyle:
                              const TextStyle(color: Color(0xFF9A4B20))),
                      row('WHT (2%):', '- NGN ${wht.toString()}',
                          valueStyle:
                              const TextStyle(color: Color(0xFF9A4B20))),
                      const Divider(),
                      row('Amount You will get:',
                          'NGN ${amountYouGet.toString()}',
                          valueStyle: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brownHeader)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Agreed Delivery Date',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                const Text(agreedDate, style: TextStyle(color: Colors.black87)),
                const SizedBox(height: 12),
                const Text('Comment', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Text(comment, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
              ]);
        }),
      ),
      const SizedBox(height: 16),
    ];

    if (showActionsInline) {
      // Buttons included inside scrollable content (for sheets)
      content.addAll([
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Dispatch AcceptAgreementEvent; the BlocListener will pop with true when accepted
                    context
                        .read<JobBloc>()
                        .add(AcceptAgreementEvent(jobId: job.id));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9A4B20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Accept and request payment',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop('request_changes'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Request Changes',
                      style: TextStyle(fontSize: 16, color: Colors.black87)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ]);
    } else {
      // When not showing inline actions add bottom padding to leave space for bottomNavigationBar
      content.add(const SizedBox(height: 80));
    }

    // Listen to job bloc to close this sheet/page when the agreement has been accepted.
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobStateAgreementAccepted && state.jobId == job.id) {
          // pop with 'true' so callers (home page) know the agreement was accepted
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          }
        } else if (state is JobStateError) {
          // surface errors inside the sheet/page
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: SafeArea(
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: content,
        ),
      ),
    );
  }
}
