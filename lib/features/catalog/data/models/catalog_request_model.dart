import '../../domain/entities/catalog_request.dart';
import '../../domain/entities/catalog_request_status.dart';

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
    // New comprehensive fields
    super.catalog,
    super.client,
    super.deliveryDateTime,
    super.requestStatus,
    super.isArtisanApproved,
    super.isClientApproved,
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

    // Parse client object
    CatalogClient? parseClient(Map? clientMap) {
      if (clientMap == null) return null;
      return CatalogClient(
        id: clientMap['id'] ?? 0,
        firstName: clientMap['first_name']?.toString() ?? '',
        lastName: clientMap['last_name']?.toString() ?? '',
        email: clientMap['email']?.toString(),
        phone: clientMap['phone']?.toString(),
        homeAddress: clientMap['home_address']?.toString(),
        profilePic: clientMap['profile_pic']?.toString(),
        stateName: clientMap['state']?['name']?.toString(),
      );
    }

    // Parse catalog product object
    CatalogProduct? parseCatalog(Map? catalogMap) {
      if (catalogMap == null || catalogMap.isEmpty) return null;
      return CatalogProduct(
        id: catalogMap['id'] ?? 0,
        title: catalogMap['title']?.toString() ?? '',
        description: catalogMap['description']?.toString() ?? '',
        pictures: extractPictures(catalogMap),
      );
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

      // New comprehensive fields from artisan_app analysis
      catalog: parseCatalog(catalog),
      client: parseClient(client),
      deliveryDateTime: parseDate(json['delivery_date']),
      requestStatus: CatalogRequestStatusExtension.fromString(
          json['status']?.toString() ?? 'pending'),
      isArtisanApproved: json['is_artisan_approved'] == true,
      isClientApproved: json['is_client_approved'] == true,
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
        // New comprehensive fields
        catalog: catalog,
        client: client,
        deliveryDateTime: deliveryDateTime,
        requestStatus: requestStatus,
        isArtisanApproved: isArtisanApproved,
        isClientApproved: isClientApproved,
      );
}
