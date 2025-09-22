import 'package:equatable/equatable.dart';

class CatalogMaterial extends Equatable {
  final String description;
  final int? quantity;
  final int? price;
  const CatalogMaterial({required this.description, this.quantity, this.price});
  @override
  List<Object?> get props => [description, quantity, price];
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
  });

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
        projectStatus
      ];
}
