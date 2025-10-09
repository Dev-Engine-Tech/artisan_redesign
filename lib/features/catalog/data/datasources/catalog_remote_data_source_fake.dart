import 'dart:async';

import 'package:artisans_circle/features/catalog/data/models/catalog_item_model.dart';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_remote_data_source.dart';

/// Simple in-memory fake remote data source used for development and widget tests.
/// Returns deterministic sample catalog data quickly without network calls.
class CatalogRemoteDataSourceFake implements CatalogRemoteDataSource {
  final List<CatalogItemModel> _catalogItems = List.generate(
    6,
    (index) => CatalogItemModel(
      id: 'catalog_$index',
      title: _getTitleByIndex(index),
      description: _getDescriptionByIndex(index),
      priceMin: _getPriceMin(index),
      priceMax: _getPriceMax(index),
      projectTimeline: _getTimelineByIndex(index),
      imageUrl: null, // No images in fake data for simplicity
      ownerName: 'Artisan Demo ${index + 1}',
    ),
  );

  static String _getTitleByIndex(int index) {
    final titles = [
      'Custom Wooden Furniture',
      'Home Electrical Installation',
      'Plumbing Services',
      'Interior Design Consultation',
      'Garden Landscaping',
      'Tile Installation',
    ];
    return titles[index % titles.length];
  }

  static String _getDescriptionByIndex(int index) {
    final descriptions = [
      'High-quality custom wooden furniture crafted with precision and attention to detail.',
      'Professional electrical installation and repair services for residential properties.',
      'Complete plumbing solutions including repairs, installations, and maintenance.',
      'Expert interior design consultation to transform your living space.',
      'Beautiful garden landscaping and outdoor space design services.',
      'Professional tile installation for bathrooms, kitchens, and floors.',
    ];
    return descriptions[index % descriptions.length];
  }

  static int _getPriceMin(int index) {
    final prices = [50000, 75000, 30000, 100000, 80000, 40000];
    return prices[index % prices.length];
  }

  static int _getPriceMax(int index) {
    final prices = [150000, 200000, 100000, 300000, 250000, 120000];
    return prices[index % prices.length];
  }

  static String _getTimelineByIndex(int index) {
    final timelines = [
      '1-2 weeks',
      '3-5 days',
      '1 week',
      '2-4 weeks',
      '1-3 weeks',
      '2-3 days',
    ];
    return timelines[index % timelines.length];
  }

  @override
  Future<List<CatalogItemModel>> getMyCatalogItems({int page = 1}) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 500));

    // Return all items for simplicity in fake data
    return List.from(_catalogItems);
  }

  @override
  Future<List<CatalogItemModel>> getCatalogByUser(String userId,
      {int page = 1}) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 500));

    // Return subset of items for demo purposes
    return _catalogItems.take(3).toList();
  }

  @override
  Future<CatalogItemModel> createCatalog({
    required String title,
    required String subCategoryId,
    required String description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> imagePaths = const [],
    bool instantSelling = false,
    String? brand,
    String? condition,
    String? salesCategory,
    bool warranty = false,
    bool delivery = false,
  }) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));

    final newItem = CatalogItemModel(
      id: 'catalog_new_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      priceMin: priceMin,
      priceMax: priceMax,
      projectTimeline: projectTimeline,
      imageUrl: null,
      ownerName: 'Current User',
      instantSelling: instantSelling,
      brand: brand,
      condition: condition,
      salesCategory: salesCategory,
      warranty: warranty,
      delivery: delivery,
    );

    _catalogItems.add(newItem);
    return newItem;
  }

  @override
  Future<CatalogItemModel> updateCatalog({
    required String id,
    String? title,
    String? subCategoryId,
    String? description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> newImagePaths = const [],
    bool? instantSelling,
    String? brand,
    String? condition,
    String? salesCategory,
    bool? warranty,
    bool? delivery,
  }) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 600));

    final index = _catalogItems.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw Exception('Catalog item not found');
    }

    final existing = _catalogItems[index];
    final updated = CatalogItemModel(
      id: existing.id,
      title: title ?? existing.title,
      description: description ?? existing.description,
      priceMin: priceMin ?? existing.priceMin,
      priceMax: priceMax ?? existing.priceMax,
      projectTimeline: projectTimeline ?? existing.projectTimeline,
      imageUrl: existing.imageUrl,
      ownerName: existing.ownerName,
      instantSelling: instantSelling ?? existing.instantSelling,
      brand: brand ?? existing.brand,
      condition: condition ?? existing.condition,
      salesCategory: salesCategory ?? existing.salesCategory,
      warranty: warranty ?? existing.warranty,
      delivery: delivery ?? existing.delivery,
    );

    _catalogItems[index] = updated;
    return updated;
  }

  @override
  Future<bool> deleteCatalog(String id) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _catalogItems.indexWhere((item) => item.id == id);
    if (index == -1) {
      return false;
    }

    _catalogItems.removeAt(index);
    return true;
  }
}
