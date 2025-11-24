import 'package:artisans_circle/features/auth/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  @JsonKey(name: 'id')
  final int? modelId;

  @JsonKey(name: 'phone')
  final String modelPhone;

  @JsonKey(name: 'first_name')
  final String modelFirstName;

  @JsonKey(name: 'last_name')
  final String modelLastName;

  @JsonKey(name: 'email')
  final String? modelEmail;

  @JsonKey(name: 'referral_code')
  final String? modelReferralCode;

  @JsonKey(name: 'is_artisan')
  final bool modelIsArtisan;

  @JsonKey(name: 'profile_picture')
  final String? modelProfilePictureUrl;

  @JsonKey(name: 'bio')
  final String? modelBio;

  @JsonKey(name: 'skills')
  final List<String>? modelSkills;

  @JsonKey(name: 'location')
  final String? modelLocation;

  @JsonKey(name: 'state')
  final String? modelState;

  @JsonKey(name: 'lga')
  final String? modelLga;

  @JsonKey(name: 'years_of_experience')
  final int? modelYearsOfExperience;

  @JsonKey(name: 'rating')
  final double? modelRating;

  @JsonKey(name: 'total_ratings')
  final int? modelTotalRatings;

  @JsonKey(name: 'is_verified')
  final bool? modelIsVerified;

  @JsonKey(name: 'is_phone_verified')
  final bool? modelIsPhoneVerified;

  @JsonKey(name: 'is_email_verified')
  final bool? modelIsEmailVerified;

  @JsonKey(name: 'id_document_url')
  final String? modelIdDocumentUrl;

  @JsonKey(name: 'selfie_url')
  final String? modelSelfieUrl;

  @JsonKey(name: 'is_active')
  final bool? modelIsActive;

  @JsonKey(name: 'created_at')
  final String? modelCreatedAt;

  @JsonKey(name: 'updated_at')
  final String? modelUpdatedAt;

  @JsonKey(name: 'total_earnings')
  final double? modelTotalEarnings;

  @JsonKey(name: 'available_balance')
  final double? modelAvailableBalance;

  @JsonKey(name: 'completed_jobs')
  final int? modelCompletedJobs;

  @JsonKey(name: 'ongoing_jobs')
  final int? modelOngoingJobs;

  UserModel({
    required this.modelPhone,
    required this.modelFirstName,
    required this.modelLastName,
    required this.modelIsArtisan,
    this.modelId,
    this.modelEmail,
    this.modelReferralCode,
    this.modelProfilePictureUrl,
    this.modelBio,
    this.modelSkills,
    this.modelLocation,
    this.modelState,
    this.modelLga,
    this.modelYearsOfExperience,
    this.modelRating,
    this.modelTotalRatings,
    this.modelIsVerified,
    this.modelIsPhoneVerified,
    this.modelIsEmailVerified,
    this.modelIdDocumentUrl,
    this.modelSelfieUrl,
    this.modelIsActive,
    this.modelCreatedAt,
    this.modelUpdatedAt,
    this.modelTotalEarnings,
    this.modelAvailableBalance,
    this.modelCompletedJobs,
    this.modelOngoingJobs,
  }) : super(
          id: modelId,
          phone: modelPhone,
          firstName: modelFirstName,
          lastName: modelLastName,
          email: modelEmail,
          referralCode: modelReferralCode,
          isArtisan: modelIsArtisan,
          profilePictureUrl: modelProfilePictureUrl,
          bio: modelBio,
          skills: modelSkills,
          location: modelLocation,
          state: modelState,
          lga: modelLga,
          yearsOfExperience: modelYearsOfExperience,
          rating: modelRating,
          totalRatings: modelTotalRatings,
          isVerified: modelIsVerified ?? false,
          isPhoneVerified: modelIsPhoneVerified ?? false,
          isEmailVerified: modelIsEmailVerified ?? false,
          idDocumentUrl: modelIdDocumentUrl,
          selfieUrl: modelSelfieUrl,
          isActive: modelIsActive ?? true,
          createdAt:
              modelCreatedAt != null ? DateTime.tryParse(modelCreatedAt) : null,
          updatedAt:
              modelUpdatedAt != null ? DateTime.tryParse(modelUpdatedAt) : null,
          totalEarnings: modelTotalEarnings,
          availableBalance: modelAvailableBalance,
          completedJobs: modelCompletedJobs,
          ongoingJobs: modelOngoingJobs,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromUser(User user) {
    return UserModel(
      modelId: user.id,
      modelPhone: user.phone,
      modelFirstName: user.firstName,
      modelLastName: user.lastName,
      modelEmail: user.email,
      modelReferralCode: user.referralCode,
      modelIsArtisan: user.isArtisan,
      modelProfilePictureUrl: user.profilePictureUrl,
      modelBio: user.bio,
      modelSkills: user.skills,
      modelLocation: user.location,
      modelState: user.state,
      modelLga: user.lga,
      modelYearsOfExperience: user.yearsOfExperience,
      modelRating: user.rating,
      modelTotalRatings: user.totalRatings,
      modelIsVerified: user.isVerified,
      modelIsPhoneVerified: user.isPhoneVerified,
      modelIsEmailVerified: user.isEmailVerified,
      modelIdDocumentUrl: user.idDocumentUrl,
      modelSelfieUrl: user.selfieUrl,
      modelIsActive: user.isActive,
      modelCreatedAt: user.createdAt?.toIso8601String(),
      modelUpdatedAt: user.updatedAt?.toIso8601String(),
      modelTotalEarnings: user.totalEarnings,
      modelAvailableBalance: user.availableBalance,
      modelCompletedJobs: user.completedJobs,
      modelOngoingJobs: user.ongoingJobs,
    );
  }
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access')
  final String accessToken;

  @JsonKey(name: 'expiry')
  final String? expiry;

  @JsonKey(name: 'firebase_access_token')
  final String? firebaseAccessToken;

  @JsonKey(name: 'phone')
  final String? phone;

  const LoginResponse({
    required this.accessToken,
    this.expiry,
    this.firebaseAccessToken,
    this.phone,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  // Accepts multiple backend variants and nested envelopes.
  factory LoginResponse.adapt(Map<String, dynamic> json) {
    Map<String, dynamic> core = json;
    final data = json['data'];
    if (data is Map) {
      core = Map<String, dynamic>.from(data);
    }
    String? access =
        (core['access'] ?? core['access_token'] ?? core['token'])?.toString();
    String? expiry =
        (core['expiry'] ?? core['expires'] ?? core['expires_in'])?.toString();
    String? firebase = (core['firebase_access_token'] ??
            core['firebase_token'] ??
            core['firebaseAccessToken'] ??
            core['firebaseToken'])
        ?.toString();
    String? phone =
        (core['phone'] ?? (core['user'] is Map ? core['user']['phone'] : null))
            ?.toString();

    if (access == null || access.isEmpty) {
      // Fall back to original mapping to surface structured errors if any
      return _$LoginResponseFromJson(json);
    }

    return LoginResponse(
      accessToken: access,
      expiry: expiry,
      firebaseAccessToken: firebase,
      phone: phone,
    );
  }
}

@JsonSerializable()
class RegisterResponse {
  @JsonKey(name: 'pin_id')
  final String? pinId;

  @JsonKey(name: 'message')
  final String? message;

  const RegisterResponse({
    this.pinId,
    this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

@JsonSerializable()
class OtpVerificationResponse {
  @JsonKey(name: 'access')
  final String? accessToken;

  @JsonKey(name: 'expiry')
  final String? expiry;

  @JsonKey(name: 'firebase_access_token')
  final String? firebaseAccessToken;

  @JsonKey(name: 'message')
  final String? message;

  const OtpVerificationResponse({
    this.accessToken,
    this.expiry,
    this.firebaseAccessToken,
    this.message,
  });

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpVerificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerificationResponseToJson(this);
}
