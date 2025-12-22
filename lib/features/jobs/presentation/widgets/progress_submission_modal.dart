import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';

class ProgressSubmissionModal extends StatefulWidget {
  final Job job;
  final VoidCallback onSubmitted;

  const ProgressSubmissionModal({
    required this.job,
    required this.onSubmitted,
    super.key,
  });

  @override
  State<ProgressSubmissionModal> createState() =>
      _ProgressSubmissionModalState();
}

class _ProgressSubmissionModalState extends State<ProgressSubmissionModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _progressController = TextEditingController();
  final List<String> _imageUrls = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _submitProgress() {
    if (!_formKey.currentState!.validate()) return;

    final progressPercent = int.tryParse(_progressController.text) ?? 0;
    if (progressPercent < 0 || progressPercent > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress must be between 0 and 100')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    context.read<JobBloc>().add(
          SubmitProgressEvent(
            jobId: widget.job.id,
            description: _descriptionController.text.trim(),
            progressPercentage: progressPercent,
            images: _imageUrls,
          ),
        );
  }

  void _addImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Progress Photo'),
        content: const Text('In a real app, this would open image picker'),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextAppButton(
            text: 'Add Sample Image',
            onPressed: () {
              setState(() {
                _imageUrls.add('https://via.placeholder.com/300x200');
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobStateProgressSubmitted) {
          setState(() {
            _isSubmitting = false;
          });
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
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: AppSpacing.paddingXL,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submit Progress',
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
                              'Update your client on project progress',
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
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: scrollController,
                      padding: AppSpacing.horizontalXL,
                      children: [
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
                            ],
                          ),
                        ),
                        AppSpacing.spaceXL,
                        Text(
                          'Progress Percentage',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brownHeader,
                                  ),
                        ),
                        AppSpacing.spaceSM,
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.softBorder),
                            borderRadius: AppRadius.radiusMD,
                          ),
                          child: TextFormField(
                            controller: _progressController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Enter progress percentage (0-100)',
                              suffixText: '%',
                              border: InputBorder.none,
                              contentPadding: AppSpacing.paddingLG,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter progress percentage';
                              }
                              final progress = int.tryParse(value.trim());
                              if (progress == null ||
                                  progress < 0 ||
                                  progress > 100) {
                                return 'Progress must be between 0 and 100';
                              }
                              return null;
                            },
                          ),
                        ),
                        AppSpacing.spaceXL,
                        Text(
                          'Progress Description',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brownHeader,
                                  ),
                        ),
                        AppSpacing.spaceSM,
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.softBorder),
                            borderRadius: AppRadius.radiusMD,
                          ),
                          child: TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText:
                                  'Describe what you have completed and what\'s next...',
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
                        AppSpacing.spaceXL,
                        Text(
                          'Progress Photos',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brownHeader,
                                  ),
                        ),
                        AppSpacing.spaceSM,
                        if (_imageUrls.isNotEmpty) ...[
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imageUrls.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadius.radiusMD,
                                    border:
                                        Border.all(color: AppColors.softBorder),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: AppRadius.radiusMD,
                                        child: (() {
                                          final fixed = sanitizeImageUrl(
                                              _imageUrls[index]);
                                          return Image.network(
                                            fixed,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              color: AppColors.softBorder,
                                              child: const Icon(
                                                  Icons.broken_image),
                                            ),
                                          );
                                        })(),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _imageUrls.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: AppSpacing.paddingXS,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          AppSpacing.spaceMD,
                        ],
                        OutlinedAppButton(
                          text: _imageUrls.isEmpty
                              ? 'Add Progress Photos'
                              : 'Add More Photos',
                          onPressed: _addImage,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
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
                    text: 'Submit Progress Update',
                    onPressed: _isSubmitting ? null : _submitProgress,
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
              'Progress Submitted!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownHeader,
                  ),
            ),
            AppSpacing.spaceMD,
            Text(
              'Your progress update has been sent to the client successfully.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.spaceXXL,
            PrimaryButton(
              text: 'Continue',
              onPressed: () {
                Navigator.of(context).pop();
                widget.onSubmitted();
              },
            ),
          ],
        ),
      ),
    );
  }
}
