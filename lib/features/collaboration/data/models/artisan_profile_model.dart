import '../../domain/entities/artisan_profile.dart';

/// Data model for artisan profile with JSON parsing
class ArtisanProfileModel extends ArtisanProfile {
  const ArtisanProfileModel({
    required super.id,
    required super.name,
    required super.occupation,
    super.rating,
    super.profilePic,
    super.location,
    super.phone,
    super.email,
  });

  factory ArtisanProfileModel.fromJson(Map<String, dynamic> json) {
    return ArtisanProfileModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      occupation: json['occupation']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      profilePic: json['profile_pic']?.toString(),
      location: json['location']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'occupation': occupation,
      'rating': rating,
      'profile_pic': profilePic,
      'location': location,
      'phone': phone,
      'email': email,
    };
  }

  ArtisanProfile toEntity() => ArtisanProfile(
        id: id,
        name: name,
        occupation: occupation,
        rating: rating,
        profilePic: profilePic,
        location: location,
        phone: phone,
        email: email,
      );
}
