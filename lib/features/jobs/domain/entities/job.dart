import 'package:equatable/equatable.dart';
import 'agreement.dart';
import 'change_request.dart';
import 'job_status.dart';
import 'material.dart';

class Job extends Equatable {
  final String id;
  final String title;
  final String category;
  final String description;
  final String address;
  final int minBudget;
  final int maxBudget;
  final String duration;
  final bool applied;
  final bool saved;
  final String thumbnailUrl;

  // Application-specific fields from artisan_app analysis
  final String? proposal;
  final String? paymentType;
  final String? desiredPay;
  final DateTime? dateCreated;
  final JobStatus status;
  final AppliedProjectStatus projectStatus;

  // Agreement and change request flows
  final Agreement? agreement;
  final ChangeRequest? changeRequest;

  // Materials for job applications
  final List<Material> materials;

  // Progress tracking
  final double? progress;
  final List<Map<String, dynamic>>? progressUpdates;

  // Additional job details
  final String? expertise;
  final String? workMode;

  // Completion and payment tracking
  final String? paymentStatus;
  final String? clientReview;
  final double? rating;
  final String? clientName;
  final String? clientId;
  final DateTime? completedDate;

  // Invitation tracking
  final int? invitationId;

  const Job({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.address,
    required this.minBudget,
    required this.maxBudget,
    required this.duration,
    this.applied = false,
    this.saved = false,
    this.thumbnailUrl = '',
    this.proposal,
    this.paymentType,
    this.desiredPay,
    this.dateCreated,
    this.status = JobStatus.pending,
    this.projectStatus = AppliedProjectStatus.ongoing,
    this.agreement,
    this.changeRequest,
    this.materials = const [],
    this.progress,
    this.progressUpdates,
    this.expertise,
    this.workMode,
    this.paymentStatus,
    this.clientReview,
    this.rating,
    this.clientName,
    this.clientId,
    this.completedDate,
    this.invitationId,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        description,
        address,
        minBudget,
        maxBudget,
        duration,
        applied,
        saved,
        thumbnailUrl,
        proposal,
        paymentType,
        desiredPay,
        dateCreated,
        status,
        projectStatus,
        agreement,
        changeRequest,
        materials,
        progress,
        progressUpdates,
        expertise,
        workMode,
        paymentStatus,
        clientReview,
        rating,
        clientName,
        clientId,
        completedDate,
        invitationId,
      ];

  /// Determines the current application status for display
  String get applicationStatus {
    if (status == JobStatus.accepted) {
      return 'Accepted';
    } else if (agreement != null) {
      return 'Review Agreement';
    } else if (changeRequest != null) {
      return 'Change request sent';
    } else if (applied) {
      return 'Application sent';
    } else {
      return 'Not applied';
    }
  }

  /// Determines if the job is in a pending state requiring action
  bool get requiresAction {
    return agreement != null && status == JobStatus.pending;
  }

  Job copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? address,
    int? minBudget,
    int? maxBudget,
    String? duration,
    bool? applied,
    bool? saved,
    String? thumbnailUrl,
    String? proposal,
    String? paymentType,
    String? desiredPay,
    DateTime? dateCreated,
    JobStatus? status,
    AppliedProjectStatus? projectStatus,
    Agreement? agreement,
    ChangeRequest? changeRequest,
    List<Material>? materials,
    double? progress,
    List<Map<String, dynamic>>? progressUpdates,
    String? expertise,
    String? workMode,
    String? paymentStatus,
    String? clientReview,
    double? rating,
    String? clientName,
    String? clientId,
    DateTime? completedDate,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      duration: duration ?? this.duration,
      applied: applied ?? this.applied,
      saved: saved ?? this.saved,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      proposal: proposal ?? this.proposal,
      paymentType: paymentType ?? this.paymentType,
      desiredPay: desiredPay ?? this.desiredPay,
      dateCreated: dateCreated ?? this.dateCreated,
      status: status ?? this.status,
      projectStatus: projectStatus ?? this.projectStatus,
      agreement: agreement ?? this.agreement,
      changeRequest: changeRequest ?? this.changeRequest,
      materials: materials ?? this.materials,
      progress: progress ?? this.progress,
      progressUpdates: progressUpdates ?? this.progressUpdates,
      expertise: expertise ?? this.expertise,
      workMode: workMode ?? this.workMode,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      clientReview: clientReview ?? this.clientReview,
      rating: rating ?? this.rating,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}
