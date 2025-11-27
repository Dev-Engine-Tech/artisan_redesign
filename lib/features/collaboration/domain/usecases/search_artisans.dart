import '../entities/artisan_search_result.dart';
import '../repositories/collaboration_repository.dart';

/// Use case for searching artisans
/// Follows Single Responsibility Principle
class SearchArtisans {
  final CollaborationRepository repository;

  SearchArtisans(this.repository);

  /// Execute search with input validation
  Future<List<ArtisanSearchResult>> call(String query) async {
    // Input validation (security)
    final sanitizedQuery = _sanitizeQuery(query);

    if (sanitizedQuery.length < 2) {
      return [];
    }

    return repository.searchArtisans(sanitizedQuery);
  }

  /// Sanitize search query to prevent injection attacks
  String _sanitizeQuery(String query) {
    return query
        .trim()
        .replaceAll(RegExp(r'[<>{}]'), '') // Remove potentially dangerous characters
        .substring(0, query.length > 50 ? 50 : query.length); // Limit length
  }
}
