import '../../domain/entities/client_profile.dart';
import '../../../jobs/data/models/job_model.dart';

class ClientProfileModel extends ClientProfile {
  const ClientProfileModel({
    required super.client,
    required super.ratingStats,
    required super.recentReviews,
    required super.jobs,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      client: ClientInfoModel.fromJson(json['client'] ?? {}),
      ratingStats: RatingStatsModel.fromJson(json['rating_stats'] ?? {}),
      recentReviews: (json['recent_reviews'] as List<dynamic>?)
              ?.map((e) => ClientReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      jobs: ClientJobsModel.fromJson(json['jobs'] ?? {}),
    );
  }
}

class ClientInfoModel extends ClientInfo {
  const ClientInfoModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    super.bio,
    super.profilePic,
    super.occupation,
    super.state,
    super.localGovernment,
  });

  factory ClientInfoModel.fromJson(Map<String, dynamic> json) {
    return ClientInfoModel(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      profilePic: json['profile_pic'] as String?,
      occupation: json['occupation'] as String?,
      state: json['state'] != null
          ? LocationInfoModel.fromJson(json['state'] as Map<String, dynamic>)
          : null,
      localGovernment: json['local_government'] != null
          ? LocationInfoModel.fromJson(
              json['local_government'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LocationInfoModel extends LocationInfo {
  const LocationInfoModel({
    required super.id,
    required super.name,
  });

  factory LocationInfoModel.fromJson(Map<String, dynamic> json) {
    return LocationInfoModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

class RatingStatsModel extends RatingStats {
  const RatingStatsModel({
    required super.averageRating,
    required super.totalRatings,
  });

  factory RatingStatsModel.fromJson(Map<String, dynamic> json) {
    return RatingStatsModel(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
    );
  }
}

class ClientReviewModel extends ClientReview {
  const ClientReviewModel({
    required super.id,
    required super.rating,
    required super.ratingLabel,
    super.comment,
    required super.rater,
    required super.timeAgo,
  });

  factory ClientReviewModel.fromJson(Map<String, dynamic> json) {
    return ClientReviewModel(
      id: json['id'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      ratingLabel: json['rating_label'] as String? ?? '',
      comment: json['comment'] as String?,
      rater: ReviewRaterModel.fromJson(json['rater'] ?? {}),
      timeAgo: json['time_ago'] as String? ?? '',
    );
  }
}

class ReviewRaterModel extends ReviewRater {
  const ReviewRaterModel({
    required super.id,
    required super.firstName,
    required super.fullName,
    super.profilePicUrl,
  });

  factory ReviewRaterModel.fromJson(Map<String, dynamic> json) {
    return ReviewRaterModel(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      profilePicUrl: json['profile_pic_url'] as String?,
    );
  }
}

class ClientJobsModel extends ClientJobs {
  const ClientJobsModel({
    required super.recent,
    required super.ongoing,
    required super.completed,
  });

  factory ClientJobsModel.fromJson(Map<String, dynamic> json) {
    return ClientJobsModel(
      recent: (json['recent'] as List<dynamic>?)
              ?.map((e) => JobModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ongoing: (json['ongoing'] as List<dynamic>?)
              ?.map((e) => JobModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      completed: (json['completed'] as List<dynamic>?)
              ?.map((e) => JobModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
