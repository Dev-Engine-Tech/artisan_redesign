import 'package:artisans_circle/features/jobs/domain/entities/job.dart';

/// Client profile entity
class ClientProfile {
  final ClientInfo client;
  final RatingStats ratingStats;
  final List<ClientReview> recentReviews;
  final ClientJobs jobs;

  const ClientProfile({
    required this.client,
    required this.ratingStats,
    required this.recentReviews,
    required this.jobs,
  });
}

/// Client basic information
class ClientInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? bio;
  final String? profilePic;
  final String? occupation;
  final LocationInfo? state;
  final LocationInfo? localGovernment;

  const ClientInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.bio,
    this.profilePic,
    this.occupation,
    this.state,
    this.localGovernment,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get location {
    if (localGovernment != null && state != null) {
      return '${localGovernment!.name}, ${state!.name}';
    } else if (state != null) {
      return state!.name;
    }
    return 'Location not specified';
  }
}

/// Location information
class LocationInfo {
  final int id;
  final String name;

  const LocationInfo({
    required this.id,
    required this.name,
  });
}

/// Rating statistics
class RatingStats {
  final double averageRating;
  final int totalRatings;

  const RatingStats({
    required this.averageRating,
    required this.totalRatings,
  });
}

/// Client review
class ClientReview {
  final int id;
  final int rating;
  final String ratingLabel;
  final String? comment;
  final ReviewRater rater;
  final String timeAgo;

  const ClientReview({
    required this.id,
    required this.rating,
    required this.ratingLabel,
    this.comment,
    required this.rater,
    required this.timeAgo,
  });
}

/// Review rater information
class ReviewRater {
  final int id;
  final String firstName;
  final String fullName;
  final String? profilePicUrl;

  const ReviewRater({
    required this.id,
    required this.firstName,
    required this.fullName,
    this.profilePicUrl,
  });
}

/// Client jobs categorized by status
class ClientJobs {
  final List<Job> recent;
  final List<Job> ongoing;
  final List<Job> completed;

  const ClientJobs({
    required this.recent,
    required this.ongoing,
    required this.completed,
  });

  int get totalJobs => recent.length + ongoing.length + completed.length;
}
