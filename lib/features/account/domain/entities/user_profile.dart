import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? profileImage;
  final String? jobTitle;
  final String? bio;
  final String? location;
  final List<String> skills;
  final bool isVerified;
  final List<WorkExperience> workExperience;
  final List<Education> education;
  final int? yearsOfExperience;

  const UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.profileImage,
    this.jobTitle,
    this.bio,
    this.location,
    this.skills = const [],
    this.isVerified = false,
    this.workExperience = const [],
    this.education = const [],
    this.yearsOfExperience,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        profileImage,
        jobTitle,
        bio,
        location,
        skills,
        isVerified,
        workExperience,
        education,
        yearsOfExperience,
      ];
}

class WorkExperience extends Equatable {
  final String id;
  final String jobTitle;
  final String companyName;
  final String? location;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;

  const WorkExperience({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.startDate,
    this.location,
    this.description,
    this.endDate,
    this.isCurrent = false,
  });

  @override
  List<Object?> get props => [
        id,
        jobTitle,
        companyName,
        location,
        description,
        startDate,
        endDate,
        isCurrent,
      ];
}

class Education extends Equatable {
  final String id;
  final String schoolName;
  final String fieldOfStudy;
  final String? degree;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;

  const Education({
    required this.id,
    required this.schoolName,
    required this.fieldOfStudy,
    required this.startDate,
    this.degree,
    this.endDate,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        schoolName,
        fieldOfStudy,
        degree,
        startDate,
        endDate,
        description,
      ];
}
