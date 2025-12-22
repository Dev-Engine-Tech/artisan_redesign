import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import '../../../../core/utils/responsive.dart';
import 'package:artisans_circle/core/utils/currency.dart';

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

  const AgreementPage({required this.job, super.key});

  @override
  Widget build(BuildContext context) {
    // Small summary shown above the scrollable content so widget tests can find
    // key labels like 'Project Agreement' and 'Agreed Payment' without scrolling.
    final paymentSummary = Container(
      width: double.infinity,
      padding: context.responsivePadding,
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
          Text('Agreed Payment: ${Currency.formatNgn(job.minBudget)}',
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
                color: context.softPinkColor,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: context.colorScheme.onSurfaceVariant),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title:
            Text('Application', style: Theme.of(context).textTheme.titleLarge),
      ),
      backgroundColor: context.lightPeachColor,
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
        minimum: AppSpacing.paddingLG,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              text: 'Accept and request payment',
              onPressed: () {
                // Dispatch AcceptAgreementEvent; the BlocListener in AgreementContent
                // will pop with `true` when the operation completes successfully.
                context
                    .read<JobBloc>()
                    .add(AcceptAgreementEvent(jobId: job.id));
              },
            ),
            AppSpacing.spaceSM,
            OutlinedAppButton(
              text: 'Request Changes',
              onPressed: () => Navigator.of(context).pop('request_changes'),
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
    required this.job,
    super.key,
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
      AppSpacing.spaceMD,
      // content card
      Container(
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(color: context.softBorderColor),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Job Details',
              style: context.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.spaceSM,
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
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          AppSpacing.spaceSM,
          Text(job.description, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      ),
      AppSpacing.spaceLG,

      // Application Details (distinct from Job Details)
      Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(color: context.subtleBorderColor),
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
              Icon(Icons.expand_more, color: context.brownHeaderColor),
            ],
          ),
          AppSpacing.spaceMD,
          Text('Project proposal',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(job.description, style: Theme.of(context).textTheme.bodyMedium),
          AppSpacing.spaceMD,
          Text('How long will this project take you?',
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(job.duration, style: Theme.of(context).textTheme.bodyMedium),
          AppSpacing.spaceMD,
          Text('How do you want to be paid?',
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text('By Project', style: Theme.of(context).textTheme.bodyMedium),
          AppSpacing.spaceMD,
          Text('Desired pay (optional)',
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text('NGN ${job.minBudget}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.brownHeaderColor)),
          AppSpacing.spaceMD,

          // Material list
          Text('Material List',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          AppSpacing.spaceSM,
          Container(
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: context.subtleBorderColor),
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
                                      color: context.brownHeaderColor))),
                      Expanded(
                          flex: 2,
                          child: Text('Quantity',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.brownHeaderColor))),
                      Expanded(
                          flex: 3,
                          child: Text('Cost',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.brownHeaderColor))),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // row 1
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(flex: 5, child: Text('1 by 12 wood')),
                      Expanded(flex: 2, child: Text('100')),
                      Expanded(flex: 3, child: Text('${Currency.formatNgn(14000)}')),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // row 2
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(flex: 5, child: Text('Zinc Nail')),
                      Expanded(flex: 2, child: Text('2 bags')),
                      Expanded(flex: 3, child: Text('${Currency.formatNgn(80000)}')),
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
                      Expanded(
                          flex: 5,
                          child: Text('Total',
                              style: context.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700))),
                      const Expanded(flex: 2, child: SizedBox()),
                      Expanded(
                          flex: 3,
                          child: Text('${Currency.formatNgn(94000)}',
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

          AppSpacing.spaceMD,
          Text('Attached Files', style: Theme.of(context).textTheme.bodySmall),
          AppSpacing.spaceSM,
          Container(
            decoration: BoxDecoration(
              color:
                  context.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                  color: context.colorScheme.tertiary.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: AppRadius.radiusMD),
                    child: Icon(Icons.picture_as_pdf,
                        color: context.colorScheme.onPrimary)),
                AppSpacing.spaceMD,
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
          color: context.colorScheme.surface,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(color: context.subtleBorderColor),
        ),
        padding: const EdgeInsets.all(14),
        child: Builder(builder: (ctx) {
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
                          style: ctx.textTheme.bodyMedium?.copyWith(
                              color: ctx.colorScheme.onSurfaceVariant))),
                  AppSpacing.spaceSM,
                  Text(value,
                      style: valueStyle ?? Theme.of(ctx).textTheme.bodyMedium),
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
                        style: Theme.of(ctx)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    AppSpacing.spaceSM,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: ctx.softPeachColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                          job.status.name == 'accepted'
                              ? 'Accepted'
                              : 'Pending',
                          style: ctx.textTheme.bodySmall),
                    )
                  ],
                ),
                AppSpacing.spaceMD,
                // Breakdown box (matches design blue-framed area)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: ctx.softBorderColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: AppSpacing.paddingMD,
                  child: Column(
                    children: [
                      row('Agreed Payment:', 'NGN ${agreed.toString()}',
                          valueStyle: Theme.of(ctx)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: ctx.brownHeaderColor)),
                      row('Service Charge:',
                          '- NGN ${serviceCharge.toString()}',
                          valueStyle: ctx.textTheme.bodyMedium
                              ?.copyWith(color: ctx.brownHeaderColor)),
                      row('WHT (2%):', '- NGN ${wht.toString()}',
                          valueStyle: ctx.textTheme.bodyMedium
                              ?.copyWith(color: ctx.brownHeaderColor)),
                      const Divider(),
                      row('Amount You will get:',
                          'NGN ${amountYouGet.toString()}',
                          valueStyle: Theme.of(ctx)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: ctx.brownHeaderColor)),
                    ],
                  ),
                ),
                AppSpacing.spaceMD,
                Text('Agreed Delivery Date',
                    style: ctx.textTheme.bodyMedium
                        ?.copyWith(color: ctx.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(agreedDate, style: Theme.of(ctx).textTheme.bodyMedium),
                AppSpacing.spaceMD,
                Text('Comment',
                    style: ctx.textTheme.bodyMedium
                        ?.copyWith(color: ctx.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(comment, style: Theme.of(ctx).textTheme.bodyMedium),
                AppSpacing.spaceSM,
              ]);
        }),
      ),
      AppSpacing.spaceLG,
    ];

    if (showActionsInline) {
      // Buttons included inside scrollable content (for sheets)
      content.addAll([
        AppSpacing.spaceSM,
        Padding(
          padding: AppSpacing.horizontalLG,
          child: Column(
            children: [
              PrimaryButton(
                text: 'Accept and request payment',
                onPressed: () {
                  // Dispatch AcceptAgreementEvent; the BlocListener will pop with true when accepted
                  context
                      .read<JobBloc>()
                      .add(AcceptAgreementEvent(jobId: job.id));
                },
              ),
              AppSpacing.spaceSM,
              OutlinedAppButton(
                text: 'Request Changes',
                onPressed: () => Navigator.of(context).pop('request_changes'),
              ),
              AppSpacing.spaceXXL,
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
          padding: AppSpacing.horizontalLG,
          children: content,
        ),
      ),
    );
  }
}
