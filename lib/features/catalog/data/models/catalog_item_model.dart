import '../../domain/entities/catalog_item.dart';

class CatalogItemModel extends CatalogItem {
  const CatalogItemModel({
    required super.id,
    required super.title,
    required super.description,
    super.priceMin,
    super.priceMax,
    super.projectTimeline,
    super.imageUrl,
    super.ownerName,
    super.status,
    super.projectStatus,
    super.instantSelling,
    super.brand,
    super.condition,
    super.salesCategory,
    super.warranty,
    super.delivery,
  });

  factory CatalogItemModel.fromJson(Map<String, dynamic> json) {
    // Handle the actual API response structure from /catalog/api/artisan/catalog/lists/
    final catalog = json['catalog'] as Map<String, dynamic>?;
    final client = json['client'] as Map<String, dynamic>?;

    // Extract pictures from catalog
    final pictures = catalog?['pictures'] as List? ??
        json['pictures'] as List? ??
        json['images'] as List?;
    String? imageUrl;
    if (pictures != null && pictures.isNotEmpty) {
      final first = pictures.first;
      if (first is String) imageUrl = first;
      if (first is Map && first['file'] != null) {
        imageUrl = first['file'] as String;
      }
      if (first is Map && first['url'] != null) {
        imageUrl = first['url'] as String;
      }
    }

    // Extract owner name from client
    String? ownerName;
    if (client != null) {
      ownerName = [client['first_name'], client['last_name']]
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .join(' ')
          .trim();
    }
    final owner = json['user'] as Map?;
    if (ownerName == null && owner != null) {
      ownerName = [owner['first_name'], owner['last_name']]
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .join(' ')
          .trim();
    }
    ownerName ??= json['owner_name']?.toString() ?? 'Unknown';

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String && v.contains('.')) return double.tryParse(v)?.toInt();
      return int.tryParse(v.toString());
    }

    // Handle both direct catalog items and catalog request items
    final catalogData = catalog ?? json;

    bool toBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return false;
    }

    return CatalogItemModel(
      id: (catalogData['id'] ?? json['id'] ?? '').toString(),
      title: (catalogData['title'] ?? json['title'] ?? json['name'] ?? '')
          .toString(),
      description: (catalogData['description'] ??
              json['description'] ??
              json['desc'] ??
              '')
          .toString(),
      priceMin: toInt(catalogData['price_min'] ??
          json['price_min'] ??
          json['min_price'] ??
          json['payment_budget']),
      priceMax: toInt(
          catalogData['price_max'] ?? json['price_max'] ?? json['max_price']),
      projectTimeline: (catalogData['project_timeline'] ??
              json['project_timeline'] ??
              json['duration'])
          ?.toString(),
      imageUrl: imageUrl,
      ownerName: ownerName,
      status: json['status']?.toString(),
      projectStatus: json['project_status']?.toString(),
      instantSelling:
          toBool(catalogData['instant_selling'] ?? json['instant_selling']),
      brand: (catalogData['brand'] ?? json['brand'])?.toString(),
      condition: (catalogData['condition'] ?? json['condition'])?.toString(),
      salesCategory:
          (catalogData['sales_category'] ?? json['sales_category'])?.toString(),
      warranty: toBool(catalogData['warranty'] ?? json['warranty']),
      delivery: toBool(catalogData['delivery'] ?? json['delivery']),
    );
  }

  CatalogItem toEntity() => CatalogItem(
        id: id,
        title: title,
        description: description,
        priceMin: priceMin,
        priceMax: priceMax,
        projectTimeline: projectTimeline,
        imageUrl: imageUrl,
        ownerName: ownerName,
        status: status,
        projectStatus: projectStatus,
        instantSelling: instantSelling,
        brand: brand,
        condition: condition,
        salesCategory: salesCategory,
        warranty: warranty,
        delivery: delivery,
      );
}
