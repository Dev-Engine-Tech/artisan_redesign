import 'package:equatable/equatable.dart';

/// Represents an artisan's profile information for collaboration purposes
class ArtisanProfile extends Equatable {
  final int id;
  final String name;
  final String occupation;
  final double rating;
  final String? profilePic;
  final String? location;
  final String? phone;
  final String? email;

  const ArtisanProfile({
    required this.id,
    required this.name,
    required this.occupation,
    this.rating = 0.0,
    this.profilePic,
    this.location,
    this.phone,
    this.email,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        occupation,
        rating,
        profilePic,
        location,
        phone,
        email,
      ];
}
