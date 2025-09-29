// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      modelId: (json['id'] as num?)?.toInt(),
      modelPhone: json['phone'] as String,
      modelFirstName: json['first_name'] as String,
      modelLastName: json['last_name'] as String,
      modelEmail: json['email'] as String?,
      modelReferralCode: json['referral_code'] as String?,
      modelIsArtisan: json['is_artisan'] as bool,
      modelProfilePictureUrl: json['profile_picture'] as String?,
      modelBio: json['bio'] as String?,
      modelSkills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
      modelLocation: json['location'] as String?,
      modelState: json['state'] as String?,
      modelLga: json['lga'] as String?,
      modelYearsOfExperience: (json['years_of_experience'] as num?)?.toInt(),
      modelRating: (json['rating'] as num?)?.toDouble(),
      modelTotalRatings: (json['total_ratings'] as num?)?.toInt(),
      modelIsVerified: json['is_verified'] as bool?,
      modelIsPhoneVerified: json['is_phone_verified'] as bool?,
      modelIsEmailVerified: json['is_email_verified'] as bool?,
      modelIdDocumentUrl: json['id_document_url'] as String?,
      modelSelfieUrl: json['selfie_url'] as String?,
      modelIsActive: json['is_active'] as bool?,
      modelCreatedAt: json['created_at'] as String?,
      modelUpdatedAt: json['updated_at'] as String?,
      modelTotalEarnings: (json['total_earnings'] as num?)?.toDouble(),
      modelAvailableBalance: (json['available_balance'] as num?)?.toDouble(),
      modelCompletedJobs: (json['completed_jobs'] as num?)?.toInt(),
      modelOngoingJobs: (json['ongoing_jobs'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.modelId,
      'phone': instance.modelPhone,
      'first_name': instance.modelFirstName,
      'last_name': instance.modelLastName,
      'email': instance.modelEmail,
      'referral_code': instance.modelReferralCode,
      'is_artisan': instance.modelIsArtisan,
      'profile_picture': instance.modelProfilePictureUrl,
      'bio': instance.modelBio,
      'skills': instance.modelSkills,
      'location': instance.modelLocation,
      'state': instance.modelState,
      'lga': instance.modelLga,
      'years_of_experience': instance.modelYearsOfExperience,
      'rating': instance.modelRating,
      'total_ratings': instance.modelTotalRatings,
      'is_verified': instance.modelIsVerified,
      'is_phone_verified': instance.modelIsPhoneVerified,
      'is_email_verified': instance.modelIsEmailVerified,
      'id_document_url': instance.modelIdDocumentUrl,
      'selfie_url': instance.modelSelfieUrl,
      'is_active': instance.modelIsActive,
      'created_at': instance.modelCreatedAt,
      'updated_at': instance.modelUpdatedAt,
      'total_earnings': instance.modelTotalEarnings,
      'available_balance': instance.modelAvailableBalance,
      'completed_jobs': instance.modelCompletedJobs,
      'ongoing_jobs': instance.modelOngoingJobs,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) => LoginResponse(
      accessToken: json['access'] as String,
      expiry: json['expiry'] as String?,
      firebaseAccessToken: json['firebase_access_token'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) => <String, dynamic>{
      'access': instance.accessToken,
      'expiry': instance.expiry,
      'firebase_access_token': instance.firebaseAccessToken,
      'phone': instance.phone,
    };

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) => RegisterResponse(
      pinId: json['pin_id'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) => <String, dynamic>{
      'pin_id': instance.pinId,
      'message': instance.message,
    };

OtpVerificationResponse _$OtpVerificationResponseFromJson(Map<String, dynamic> json) =>
    OtpVerificationResponse(
      accessToken: json['access'] as String?,
      expiry: json['expiry'] as String?,
      firebaseAccessToken: json['firebase_access_token'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$OtpVerificationResponseToJson(OtpVerificationResponse instance) =>
    <String, dynamic>{
      'access': instance.accessToken,
      'expiry': instance.expiry,
      'firebase_access_token': instance.firebaseAccessToken,
      'message': instance.message,
    };
