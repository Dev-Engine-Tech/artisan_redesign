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
      String endpoint;
      if (next != null && next.isNotEmpty) {
        // Use the next URL directly if provided
        endpoint = next;
      } else {
        // Use the category-specific endpoint
        endpoint = ApiEndpoints.getBanners(category.apiValue);
      }

      final response = await _httpService.get(endpoint);
      
      if (response.statusCode == 200) {
        return ApiBannerModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Banners not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
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