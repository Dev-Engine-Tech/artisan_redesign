class User {
  final int? id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? email;
  final String? referralCode;
  final bool isArtisan;

  // Profile information
  final String? profilePictureUrl;
  final String? bio;
  final List<String>? skills;
  final String? location;
  final String? state;
  final String? lga;
  final int? yearsOfExperience;
  final double? rating;
  final int? totalRatings;

  // Verification-related fields
  final bool isVerified;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final String? idDocumentUrl;
  final String? selfieUrl;

  // Account status
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Earnings and statistics
  final double? totalEarnings;
  final double? availableBalance;
  final int? completedJobs;
  final int? ongoingJobs;

  User({
    this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.email,
    this.referralCode,
    required this.isArtisan,
    this.profilePictureUrl,
    this.bio,
    this.skills,
    this.location,
    this.state,
    this.lga,
    this.yearsOfExperience,
    this.rating,
    this.totalRatings,
    this.isVerified = false,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.idDocumentUrl,
    this.selfieUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.totalEarnings,
    this.availableBalance,
    this.completedJobs,
    this.ongoingJobs,
  });

  String get fullName => '$firstName $lastName';

  User copyWith({
    int? id,
    String? phone,
    String? firstName,
    String? lastName,
    String? email,
    String? referralCode,
    bool? isArtisan,
    String? profilePictureUrl,
    String? bio,
    List<String>? skills,
    String? location,
    String? state,
    String? lga,
    int? yearsOfExperience,
    double? rating,
    int? totalRatings,
    bool? isVerified,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    String? idDocumentUrl,
    String? selfieUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalEarnings,
    double? availableBalance,
    int? completedJobs,
    int? ongoingJobs,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      referralCode: referralCode ?? this.referralCode,
      isArtisan: isArtisan ?? this.isArtisan,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      state: state ?? this.state,
      lga: lga ?? this.lga,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      isVerified: isVerified ?? this.isVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      availableBalance: availableBalance ?? this.availableBalance,
      completedJobs: completedJobs ?? this.completedJobs,
      ongoingJobs: ongoingJobs ?? this.ongoingJobs,
    );
  }
}
