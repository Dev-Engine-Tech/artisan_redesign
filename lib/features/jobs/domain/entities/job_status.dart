/// Enumeration for job application status
enum JobStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  changeRequested,
}

/// Enumeration for applied project status
enum AppliedProjectStatus {
  ongoing,
  completed,
  paused,
}

/// Extension to convert JobStatus to string
extension JobStatusExtension on JobStatus {
  String get name {
    switch (this) {
      case JobStatus.pending:
        return 'pending';
      case JobStatus.accepted:
        return 'accepted';
      case JobStatus.rejected:
        return 'rejected';
      case JobStatus.inProgress:
        return 'inProgress';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.changeRequested:
        return 'changeRequested';
    }
  }

  static JobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return JobStatus.accepted;
      case 'rejected':
        return JobStatus.rejected;
      case 'inprogress':
      case 'in_progress':
        return JobStatus.inProgress;
      case 'completed':
        return JobStatus.completed;
      case 'changerequested':
      case 'change_requested':
        return JobStatus.changeRequested;
      case 'pending':
      default:
        return JobStatus.pending;
    }
  }
}

/// Extension to convert AppliedProjectStatus to string
extension AppliedProjectStatusExtension on AppliedProjectStatus {
  String get name {
    switch (this) {
      case AppliedProjectStatus.ongoing:
        return 'ongoing';
      case AppliedProjectStatus.completed:
        return 'completed';
      case AppliedProjectStatus.paused:
        return 'paused';
    }
  }

  static AppliedProjectStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppliedProjectStatus.completed;
      case 'paused':
        return AppliedProjectStatus.paused;
      case 'ongoing':
      default:
        return AppliedProjectStatus.ongoing;
    }
  }
}