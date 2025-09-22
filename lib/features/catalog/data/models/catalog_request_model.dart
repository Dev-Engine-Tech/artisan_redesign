import '../../domain/entities/catalog_request.dart';

class CatalogRequestModel extends CatalogRequest {
  const CatalogRequestModel({
    required super.id,
    required super.title,
    required super.description,
    super.clientName,
    super.clientPhone,
    super.materials = const [],
    super.createdAt,
    super.status,
    super.catalogTitle,
    super.paymentBudget,
    super.priceMin,
    super.priceMax,
    super.catalogPictures = const [],
    super.deliveryDate,
    super.projectStatus,
  });

  static CatalogMaterial _materialFrom(Map<String, dynamic> m) {
    int? toInt(dynamic v) =>
        v == null ? null : (v is int ? v : int.tryParse(v.toString()));
    return CatalogMaterial(
      description: (m['description'] ?? m['material'] ?? '').toString(),
      quantity: toInt(m['quantity']),
      price: toInt(m['price']),
    );
  }

  factory CatalogRequestModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map? ?? json['user'] as Map?;
    final catalog = json['catalog'] as Map? ?? <String, dynamic>{};
    final materialsList = (json['materials'] as List?) ??
        (json['material_list'] as List?) ??
        const [];

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    // Extract pictures from catalog object
    List<String> extractPictures(Map catalog) {
      final pictures = catalog['pictures'] as List? ?? [];
      return pictures
          .map((p) {
            if (p is Map && p['file'] != null) {
              return p['file'].toString();
            } else if (p is String) {
              return p;
            }
            return '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return CatalogRequestModel(
      id: (json['id'] ?? json['request_id'] ?? '').toString(),
      title: (json['title'] ?? json['product_title'] ?? json['name'] ?? '')
          .toString(),
      description:
          (json['description'] ?? json['product_description'] ?? '').toString(),
      clientName: client != null
          ? [client['first_name'], client['last_name']]
              .whereType<String>()
              .where((e) => e.isNotEmpty)
              .join(' ')
              .trim()
          : null,
      clientPhone: client != null ? client['phone']?.toString() : null,
      materials: materialsList
          .map((e) => _materialFrom(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: parseDate(json['created_at']),
      status: json['status']?.toString(),

      // Enhanced fields from API response
      catalogTitle: catalog['title']?.toString(),
      paymentBudget: json['payment_budget']?.toString(),
      priceMin: catalog['price_min']?.toString(),
      priceMax: catalog['price_max']?.toString(),
      catalogPictures: extractPictures(catalog),
      deliveryDate: json['delivery_date']?.toString(),
      projectStatus: json['project_status']?.toString(),
    );
  }

  CatalogRequest toEntity() => CatalogRequest(
        id: id,
        title: title,
        description: description,
        clientName: clientName,
        clientPhone: clientPhone,
        materials: materials,
        createdAt: createdAt,
        status: status,
        catalogTitle: catalogTitle,
        paymentBudget: paymentBudget,
        priceMin: priceMin,
        priceMax: priceMax,
        catalogPictures: catalogPictures,
        deliveryDate: deliveryDate,
        projectStatus: projectStatus,
      );
}
