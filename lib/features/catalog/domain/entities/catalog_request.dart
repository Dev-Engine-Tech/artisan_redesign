import 'package:equatable/equatable.dart';
import 'catalog_request_status.dart';

class CatalogMaterial extends Equatable {
  final String description;
  final int? quantity;
  final int? price;
  const CatalogMaterial({required this.description, this.quantity, this.price});
  @override
  List<Object?> get props => [description, quantity, price];
}

/// Enhanced client information structure
class CatalogClient extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? homeAddress;
  final String? profilePic;
  final String? stateName;

  const CatalogClient({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.homeAddress,
    this.profilePic,
    this.stateName,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        homeAddress,
        profilePic,
        stateName
      ];
}

/// Enhanced catalog product structure
class CatalogProduct extends Equatable {
  final int id;
  final String title;
  final String description;
  final List<String> pictures;

  const CatalogProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.pictures,
  });

  String get primaryImage => pictures.isNotEmpty ? pictures.first : '';

  @override
  List<Object?> get props => [id, title, description, pictures];
}

class CatalogRequest extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? clientName;
  final String? clientPhone;
  final List<CatalogMaterial> materials;
  final DateTime? createdAt;
  final String? status; // pending/approved/declined

  // Enhanced fields for rich display
  final String? catalogTitle; // Title from nested catalog object
  final String? paymentBudget; // Budget from payment_budget field
  final String? priceMin; // Min price from catalog
  final String? priceMax; // Max price from catalog
  final List<String> catalogPictures; // Pictures from catalog object
  final String? deliveryDate; // Delivery date
  final String? projectStatus; // Project status (ongoing, completed, etc.)

  // New comprehensive fields from artisan_app analysis
  final CatalogProduct? catalog;
  final CatalogClient? client;
  final DateTime? deliveryDateTime;
  final CatalogRequestStatus requestStatus;
  final bool isArtisanApproved;
  final bool isClientApproved;

  const CatalogRequest({
    required this.id,
    required this.title,
    required this.description,
    this.clientName,
    this.clientPhone,
    this.materials = const [],
    this.createdAt,
    this.status,
    this.catalogTitle,
    this.paymentBudget,
    this.priceMin,
    this.priceMax,
    this.catalogPictures = const [],
    this.deliveryDate,
    this.projectStatus,
    // New fields
    this.catalog,
    this.client,
    this.deliveryDateTime,
    this.requestStatus = CatalogRequestStatus.pending,
    this.isArtisanApproved = false,
    this.isClientApproved = false,
  });

  /// Determines if both parties have approved the request
  bool get isBothApproved => isArtisanApproved && isClientApproved;

  /// Gets the approval count for UI display (like artisan_app)
  int get approvalCount {
    int count = 0;
    if (isArtisanApproved) count++;
    if (isClientApproved) count++;
    return count;
  }

  /// Determines if the request can be modified
  bool get canModify =>
      requestStatus == CatalogRequestStatus.pending && isArtisanApproved;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        clientName,
        clientPhone,
        materials,
        createdAt,
        status,
        catalogTitle,
        paymentBudget,
        priceMin,
        priceMax,
        catalogPictures,
        deliveryDate,
        projectStatus,
        catalog,
        client,
        deliveryDateTime,
        requestStatus,
        isArtisanApproved,
        isClientApproved,
      ];

  CatalogRequest copyWith({
    String? id,
    String? title,
    String? description,
    String? clientName,
    String? clientPhone,
    List<CatalogMaterial>? materials,
    DateTime? createdAt,
    String? status,
    String? catalogTitle,
    String? paymentBudget,
    String? priceMin,
    String? priceMax,
    List<String>? catalogPictures,
    String? deliveryDate,
    String? projectStatus,
    CatalogProduct? catalog,
    CatalogClient? client,
    DateTime? deliveryDateTime,
    CatalogRequestStatus? requestStatus,
    bool? isArtisanApproved,
    bool? isClientApproved,
  }) {
    return CatalogRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      materials: materials ?? this.materials,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      catalogTitle: catalogTitle ?? this.catalogTitle,
      paymentBudget: paymentBudget ?? this.paymentBudget,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      catalogPictures: catalogPictures ?? this.catalogPictures,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      projectStatus: projectStatus ?? this.projectStatus,
      catalog: catalog ?? this.catalog,
      client: client ?? this.client,
      deliveryDateTime: deliveryDateTime ?? this.deliveryDateTime,
      requestStatus: requestStatus ?? this.requestStatus,
      isArtisanApproved: isArtisanApproved ?? this.isArtisanApproved,
      isClientApproved: isClientApproved ?? this.isClientApproved,
    );
  }
}
