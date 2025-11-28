import 'package:equatable/equatable.dart';

/// Domain entity for artisan search results
class ArtisanSearchResult extends Equatable {
  final int id;
  final String name;
  final String occupation;
  final double rating;
  final String? profilePicture;
  final String? phone;

  const ArtisanSearchResult({
    required this.id,
    required this.name,
    required this.occupation,
    this.rating = 0.0,
    this.profilePicture,
    this.phone,
  });

  @override
  List<Object?> get props =>
      [id, name, occupation, rating, profilePicture, phone];
}
