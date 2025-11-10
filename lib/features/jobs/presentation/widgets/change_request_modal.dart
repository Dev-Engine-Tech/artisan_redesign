import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';

class ChangeRequestModal extends StatefulWidget {
  final Job job;

  const ChangeRequestModal({
    required this.job,
    super.key,
  });

  @override
  State<ChangeRequestModal> createState() => _ChangeRequestModalState();
}

class _ChangeRequestModalState extends State<ChangeRequestModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedChangeType;
  bool _isSubmitting = false;

  final List<Map<String, String>> _changeTypes = [
    {'value': 'price', 'label': 'Price adjustment needed'},
    {'value': 'timeline', 'label': 'Timeline changes required'},
    {'value': 'scope', 'label': 'Project scope modification'},
    {'value': 'materials', 'label': 'Material list changes'},
    {'value': 'other', 'label': 'Other changes'},
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitChangeRequest() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChangeType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a change type')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final changeTypeLabel = _changeTypes
        .firstWhere((type) => type['value'] == _selectedChangeType)['label'];

    final reason = '$changeTypeLabel: ${_reasonController.text.trim()}';

    context.read<JobBloc>().add(
          RequestChangeEvent(
            jobId: widget.job.id,
            reason: reason,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobStateChangeRequested && state.jobId == widget.job.id) {
          setState(() {
            _isSubmitting = false;
          });
          Navigator.of(context).pop(true);
          _showSuccessDialog();
        } else if (state is JobStateError) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: AppSpacing.paddingXL,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Request Changes',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brownHeader,
                                  ),
                            ),
                            AppSpacing.spaceXS,
                            Text(
                              'Specify what changes you need for this project',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.black54,
                                  ),
                            ),
                          ],
                        ),
                      ),
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
                ),

                // Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: scrollController,
                      padding: AppSpacing.horizontalXL,
                      children: [
                        // Job info card
                        Container(
                          padding: AppSpacing.paddingLG,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: AppRadius.radiusLG,
                            border: Border.all(color: AppColors.softBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brownHeader,
                                    ),
                              ),
                              AppSpacing.spaceXS,
                              Text(
                                widget.job.category,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.black54,
                                    ),
                              ),
                              AppSpacing.spaceSM,
                              Row(
                                children: [
                                  Text(
                                    'Agreed Amount: ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black54,
                                        ),
                                  ),
                                  Text(
                                    'NGN ${widget.job.minBudget.toString().replaceAllMapped(
                                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                                          (match) => '${match[1]},',
                                        )}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.brownHeader,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.spaceXL,

                        // Change type selection
                        Text(
                          'What type of change do you need?',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brownHeader,
                                  ),
                        ),
                        AppSpacing.spaceMD,

                        ..._changeTypes.map((changeType) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedChangeType = changeType['value'];
                                });
                              },
                              borderRadius: AppRadius.radiusMD,
                              child: Container(
                                padding: AppSpacing.paddingMD,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedChangeType ==
                                            changeType['value']
                                        ? AppColors.orange
                                        : AppColors.softBorder,
                                    width: _selectedChangeType ==
                                            changeType['value']
                                        ? 2
                                        : 1,
                                  ),
                                  borderRadius: AppRadius.radiusMD,
                                  color: _selectedChangeType ==
                                          changeType['value']
                                      ? AppColors.orange.withValues(alpha: 0.05)
                                      : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedChangeType ==
                                                  changeType['value']
                                              ? AppColors.orange
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        color: _selectedChangeType ==
                                                changeType['value']
                                            ? AppColors.orange
                                            : Colors.white,
                                      ),
                                      child: _selectedChangeType ==
                                              changeType['value']
                                          ? const Icon(
                                              Icons.check,
                                              size: 12,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    AppSpacing.spaceMD,
                                    Expanded(
                                      child: Text(
                                        changeType['label']!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: _selectedChangeType ==
                                                      changeType['value']
                                                  ? AppColors.brownHeader
                                                  : Colors.black87,
                                              fontWeight: _selectedChangeType ==
                                                      changeType['value']
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        AppSpacing.spaceXL,

                        // Reason text field
                        Text(
                          'Explain the changes you need',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brownHeader,
                                  ),
                        ),
                        AppSpacing.spaceMD,

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.softBorder),
                            borderRadius: AppRadius.radiusMD,
                          ),
                          child: TextFormField(
                            controller: _reasonController,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText:
                                  'Please provide detailed explanation of the changes needed...',
                              border: InputBorder.none,
                              contentPadding: AppSpacing.paddingLG,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length < 20) {
                                return 'Please provide more details (minimum 20 characters)';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(
                            height: 100), // Extra space for bottom button
                      ],
                    ),
                  ),
                ),

                // Submit button
                Container(
                  padding: AppSpacing.paddingXL,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: PrimaryButton(
                    text: 'Submit Change Request',
                    onPressed: _isSubmitting ? null : _submitChangeRequest,
                    isLoading: _isSubmitting,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXL,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.green.shade600,
              ),
            ),
            AppSpacing.spaceLG,
            Text(
              'Request Sent!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownHeader,
                  ),
            ),
            AppSpacing.spaceMD,
            Text(
              'Your change request has been submitted successfully. The client will be notified and will respond soon.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.spaceXXL,
            PrimaryButton(
              text: 'OK',
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show the change request modal
Future<bool?> showChangeRequestModal(BuildContext context, Job job) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ChangeRequestModal(job: job),
  );
}
