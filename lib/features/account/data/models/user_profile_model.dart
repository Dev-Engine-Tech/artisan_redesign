import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required String id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImage,
    String? jobTitle,
    String? bio,
    String? location,
    List<String> skills = const [],
    bool isVerified = false,
    List<WorkExperience> workExperience = const [],
    List<Education> education = const [],
    int? yearsOfExperience,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          profileImage: profileImage,
          jobTitle: jobTitle,
          bio: bio,
          location: location,
          skills: skills,
          isVerified: isVerified,
          workExperience: workExperience,
          education: education,
          yearsOfExperience: yearsOfExperience,
        );

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      firstName:
          json['first_name']?.toString() ?? json['firstName']?.toString(),
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      profileImage:
          json['profile_image']?.toString() ?? json['profilePic']?.toString(),
      jobTitle: json['job_title']?.toString() ?? json['occupation']?.toString(),
      bio: json['bio']?.toString(),
      location: json['location']?.toString(),
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      workExperience: (json['work_experience'] as List?)
              ?.map((e) =>
                  WorkExperienceModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      education: (json['education'] as List?)
              ?.map(
                  (e) => EducationModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      yearsOfExperience: (json['years_of_experience'] as num?)?.toInt() ??
          json['yearsOfExperience'] as int?,
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'job_title': jobTitle,
      'bio': bio,
      'location': location,
      'skills': skills,
      'work_experience': workExperience
          .map((e) => (e as WorkExperienceModel).toJson())
          .toList(),
      'education':
          education.map((e) => (e as EducationModel).toJson()).toList(),
      'years_of_experience': yearsOfExperience,
      'is_verified': isVerified,
    };
  }
}

class WorkExperienceModel extends WorkExperience {
  const WorkExperienceModel({
    required String id,
    required String jobTitle,
    required String companyName,
    String? location,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    bool isCurrent = false,
  }) : super(
          id: id,
          jobTitle: jobTitle,
          companyName: companyName,
          location: location,
          description: description,
          startDate: startDate,
          endDate: endDate,
          isCurrent: isCurrent,
        );

  factory WorkExperienceModel.fromJson(Map<String, dynamic> json) {
    return WorkExperienceModel(
      id: json['id']?.toString() ?? '',
      jobTitle: json['job_title']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      location: json['location']?.toString(),
      description: json['description']?.toString(),
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ??
          DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      isCurrent: json['is_current'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'job_title': jobTitle,
        'company_name': companyName,
        'location': location,
        'description': description,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'is_current': isCurrent,
      };
}

class EducationModel extends Education {
  const EducationModel({
    required String id,
    required String schoolName,
    required String fieldOfStudy,
    String? degree,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
  }) : super(
          id: id,
          schoolName: schoolName,
          fieldOfStudy: fieldOfStudy,
          degree: degree,
          startDate: startDate,
          endDate: endDate,
          description: description,
        );

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id']?.toString() ?? '',
      schoolName: json['school_name']?.toString() ?? '',
      fieldOfStudy: json['field_of_study']?.toString() ?? '',
      degree: json['degree']?.toString(),
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ??
          DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_name': schoolName,
        'field_of_study': fieldOfStudy,
        'degree': degree,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'description': description,
      };
}
