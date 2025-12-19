import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/data/models/job_model.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/applications_list.dart';

/// Separate widget for Applications tab
class ApplicationsTabContent extends StatefulWidget {
  const ApplicationsTabContent({
    required this.applications,
    required this.onJobTap,
    required this.onApplicationUpdate,
    super.key,
  });

  final List<JobModel> applications;
  final Function(Job) onJobTap;
  final Function(List<JobModel>) onApplicationUpdate;

  @override
  State<ApplicationsTabContent> createState() => _ApplicationsTabContentState();
}

class _ApplicationsTabContentState extends State<ApplicationsTabContent> {
  @override
  void initState() {
    super.initState();
    // Applications are loaded by the parent HomePage, no need to duplicate the call
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        bool isLoading = state is JobStateLoading;
        String? errorMessage;
        List<Job> applications = [];

        if (state is JobStateError) {
          errorMessage = state.message;
        } else if (state is JobStateAppliedSuccess) {
          // Convert JobModel list to Job list for the ApplicationsList widget
          applications = state.jobs
              .map((jobModel) => Job(
                    id: jobModel.id,
                    title: jobModel.title,
                    category: jobModel.category,
                    description: jobModel.description,
                    address: jobModel.address,
                    minBudget: jobModel.minBudget,
                    maxBudget: jobModel.maxBudget,
                    duration: jobModel.duration,
                    applied: jobModel.applied,
                    thumbnailUrl: jobModel.thumbnailUrl,
                    status: jobModel.status,
                    agreement: jobModel.agreement,
                    changeRequest: jobModel.changeRequest,
                    materials: jobModel.materials,
                  ))
              .toList();
        } else {
          // Fallback to applications provided by parent when bloc doesn't currently hold applications
          applications = widget.applications
              .map((m) => Job(
                    id: m.id,
                    title: m.title,
                    category: m.category,
                    description: m.description,
                    address: m.address,
                    minBudget: m.minBudget,
                    maxBudget: m.maxBudget,
                    duration: m.duration,
                    applied: true,
                    thumbnailUrl: m.thumbnailUrl,
                    status: m.status,
                    agreement: m.agreement,
                    changeRequest: m.changeRequest,
                    materials: m.materials,
                  ))
              .toList();
        }

        return ApplicationsList(
          applications: applications,
          isLoading: isLoading,
          error: errorMessage,
          onRefresh: () {
            context.read<JobBloc>().add(LoadApplications(page: 1, limit: 10));
          },
          onApplicationUpdate: (updatedJob) {
            // Update the applications list in the parent
            final updatedApplications = applications.map((app) {
              if (app.id == updatedJob.id) {
                return updatedJob;
              }
              return app;
            }).toList();

            // Convert back to JobModel list for parent callback
            final updatedJobModels = updatedApplications
                .map((job) => JobModel(
                      id: job.id,
                      title: job.title,
                      category: job.category,
                      description: job.description,
                      address: job.address,
                      minBudget: job.minBudget,
                      maxBudget: job.maxBudget,
                      duration: job.duration,
                      applied: job.applied,
                      thumbnailUrl: job.thumbnailUrl,
                      status: job.status,
                      agreement: job.agreement,
                      changeRequest: job.changeRequest,
                      materials: job.materials,
                    ))
                .toList();

            widget.onApplicationUpdate(updatedJobModels);
          },
        );
      },
    );
  }
}
