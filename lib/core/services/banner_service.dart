import 'package:artisans_circle/core/models/banner_model.dart';
import 'package:artisans_circle/core/network/http_service.dart';
import 'package:artisans_circle/core/api/endpoints.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:dio/dio.dart';

class BannerService {
  final HttpService _httpService = getIt<HttpService>();

  Future<ApiBannerModel> getBanners({
    required BannerCategory category,
    String? next,
  }) async {
    try {
      // When using pagination "next" from backend, just hit the absolute URL as-is.
      if (next != null && next.isNotEmpty) {
        print('🎯 BANNER: Loading next page from $next');
        final response = await _httpService.get(next);
        if (response.statusCode == 200) {
          return ApiBannerModel.fromJson(response.data);
        }
        throw Exception('Failed to load next page: ${response.statusCode}');
      }

      // Try primary endpoint first
      final primary = ApiEndpoints.getBanners(category.apiValue);
      print('🎯 BANNER: Trying primary endpoint: $primary');
      try {
        final r1 = await _httpService.get(primary);
        if (r1.statusCode == 200) {
          return ApiBannerModel.fromJson(r1.data);
        }
        print('🎯 BANNER: Primary endpoint status ${r1.statusCode}');
      } on DioException catch (e) {
        print('🎯 BANNER: Primary failed: ${e.response?.statusCode}');
      }

      // Fallback 1: category route
      final alt1 = ApiEndpoints.getBannersByCategory(category.apiValue);
      print('🎯 BANNER: Trying fallback endpoint: $alt1');
      try {
        final r2 = await _httpService.get(alt1);
        if (r2.statusCode == 200) {
          return ApiBannerModel.fromJson(r2.data);
        }
        print('🎯 BANNER: Fallback1 endpoint status ${r2.statusCode}');
      } on DioException catch (e) {
        print('🎯 BANNER: Fallback1 failed: ${e.response?.statusCode}');
      }

      // Fallback 2: query param based
      final alt2 = ApiEndpoints.banners;
      print('🎯 BANNER: Trying fallback endpoint with query: $alt2?category=${category.apiValue}');
      try {
        final r3 = await _httpService.get(alt2, queryParameters: {
          'category': category.apiValue,
        });
        if (r3.statusCode == 200) {
          return ApiBannerModel.fromJson(r3.data);
        }
        print('🎯 BANNER: Fallback2 endpoint status ${r3.statusCode}');
      } on DioException catch (e) {
        print('🎯 BANNER: Fallback2 failed: ${e.response?.statusCode}');
      }

      // Fallback 3: lowercase category slug
      final slug = category.apiValue.toLowerCase().replaceAll('artisan', '');
      final alt3 = ApiEndpoints.getBannersByCategory(slug);
      print('🎯 BANNER: Trying lowercase slug endpoint: $alt3');
      try {
        final r4 = await _httpService.get(alt3);
        if (r4.statusCode == 200) {
          return ApiBannerModel.fromJson(r4.data);
        }
        print('🎯 BANNER: Fallback3 endpoint status ${r4.statusCode}');
      } on DioException catch (e) {
        print('🎯 BANNER: Fallback3 failed: ${e.response?.statusCode}');
      }

      throw Exception('No banner endpoint responded successfully');
    } on DioException catch (e) {
      print('🎯 BANNER: DioException - ${e.response?.statusCode}: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Banners not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('🎯 BANNER: Exception - $e');
      throw Exception('Failed to load banners: $e');
    }
  }

  Future<ApiBannerModel> getHomepageBanners({String? next}) async {
    return getBanners(category: BannerCategory.homepage, next: next);
  }

  Future<ApiBannerModel> getJobBanners({String? next}) async {
    return getBanners(category: BannerCategory.job, next: next);
  }

  Future<ApiBannerModel> getCatalogBanners({String? next}) async {
    return getBanners(category: BannerCategory.catalog, next: next);
  }

  Future<ApiBannerModel> getAdsBanners({String? next}) async {
    return getBanners(category: BannerCategory.ads, next: next);
  }
}
