import 'package:artisans_circle/core/models/banner_model.dart';
import 'package:artisans_circle/core/network/http_service.dart';
import 'package:artisans_circle/core/api/endpoints.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as dev;

class BannerService {
  final HttpService _httpService = getIt<HttpService>();

  Future<ApiBannerModel> getBanners({
    required BannerCategory category,
    String? next,
  }) async {
    try {
      // When using pagination "next" from backend, just hit the absolute URL as-is.
      if (next != null && next.isNotEmpty) {
        dev.log('Loading next page from $next', name: 'BannerService');
        final response = await _httpService.get(next);
        if (response.statusCode == 200) {
          return ApiBannerModel.fromJson(response.data);
        }
        throw Exception('Failed to load next page: ${response.statusCode}');
      }

      // Try primary endpoint first
      final primary = ApiEndpoints.getBanners(category.apiValue);
      dev.log('Trying primary endpoint: $primary', name: 'BannerService');
      try {
        final r1 = await _httpService.get(primary);
        if (r1.statusCode == 200) {
          return ApiBannerModel.fromJson(r1.data);
        }
        dev.log('Primary endpoint status ${r1.statusCode}',
            name: 'BannerService');
      } on DioException catch (e) {
        dev.log('Primary failed: ${e.response?.statusCode}',
            name: 'BannerService');
      }

      // Fallback 1: category route
      final alt1 = ApiEndpoints.getBannersByCategory(category.apiValue);
      dev.log('Trying fallback endpoint: $alt1', name: 'BannerService');
      try {
        final r2 = await _httpService.get(alt1);
        if (r2.statusCode == 200) {
          return ApiBannerModel.fromJson(r2.data);
        }
        dev.log('Fallback1 endpoint status ${r2.statusCode}',
            name: 'BannerService');
      } on DioException catch (e) {
        dev.log('Fallback1 failed: ${e.response?.statusCode}',
            name: 'BannerService');
      }

      // Fallback 2: query param based
      final alt2 = ApiEndpoints.banners;
      dev.log('Trying fallback with query: $alt2?category=${category.apiValue}',
          name: 'BannerService');
      try {
        final r3 = await _httpService.get(alt2, queryParameters: {
          'category': category.apiValue,
        });
        if (r3.statusCode == 200) {
          return ApiBannerModel.fromJson(r3.data);
        }
        dev.log('Fallback2 endpoint status ${r3.statusCode}',
            name: 'BannerService');
      } on DioException catch (e) {
        dev.log('Fallback2 failed: ${e.response?.statusCode}',
            name: 'BannerService');
      }

      // Fallback 3: lowercase category slug
      final slug = category.apiValue.toLowerCase().replaceAll('artisan', '');
      final alt3 = ApiEndpoints.getBannersByCategory(slug);
      dev.log('Trying lowercase slug endpoint: $alt3', name: 'BannerService');
      try {
        final r4 = await _httpService.get(alt3);
        if (r4.statusCode == 200) {
          return ApiBannerModel.fromJson(r4.data);
        }
        dev.log('Fallback3 endpoint status ${r4.statusCode}',
            name: 'BannerService');
      } on DioException catch (e) {
        dev.log('Fallback3 failed: ${e.response?.statusCode}',
            name: 'BannerService');
      }

      throw Exception('No banner endpoint responded successfully');
    } on DioException catch (e) {
      dev.log('DioException - ${e.response?.statusCode}: ${e.message}',
          name: 'BannerService', error: e);
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Banners not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      dev.log('Exception - $e', name: 'BannerService', error: e);
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
