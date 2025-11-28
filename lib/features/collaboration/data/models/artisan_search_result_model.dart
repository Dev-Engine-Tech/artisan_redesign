import '../../domain/entities/artisan_search_result.dart';

/// Data model for artisan search results
/// Handles JSON parsing with multiple field name variations
class ArtisanSearchResultModel extends ArtisanSearchResult {
  const ArtisanSearchResultModel({
    required super.id,
    required super.name,
    required super.occupation,
    super.rating,
    super.profilePicture,
    super.phone,
  });

  /// Factory constructor with flexible field mapping
  factory ArtisanSearchResultModel.fromJson(Map<String, dynamic> json) {
    return ArtisanSearchResultModel(
      id: json['id'] ?? json['user_id'] ?? 0,
      name: _extractName(json),
      occupation: _extractOccupation(json),
      rating: _extractRating(json),
      profilePicture:
          json['profile_pic'] ?? json['profile_picture'] ?? json['avatar'],
      phone: json['phone'] ?? json['phone_number'],
    );
  }

  /// Extract name with multiple fallback options
  static String _extractName(Map<String, dynamic> json) {
    if (json['name'] != null && json['name'].toString().isNotEmpty) {
      return json['name'];
    }
    if (json['full_name'] != null && json['full_name'].toString().isNotEmpty) {
      return json['full_name'];
    }

    final firstName = json['first_name']?.toString() ?? '';
    final lastName = json['last_name']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();

    return fullName.isNotEmpty ? fullName : 'Unknown';
  }

  /// Extract occupation with fallback options
  static String _extractOccupation(Map<String, dynamic> json) {
    return json['occupation'] ??
        json['category'] ??
        json['expertise'] ??
        'Artisan';
  }

  /// Extract rating safely
  static double _extractRating(Map<String, dynamic> json) {
    final rating = json['rating'];
    if (rating is num) {
      return rating.toDouble();
    }
    if (rating is String) {
      return double.tryParse(rating) ?? 0.0;
    }
    return 0.0;
  }
}
