import 'package:equatable/equatable.dart';

class CatalogItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final int? priceMin;
  final int? priceMax;
  final String? projectTimeline;
  final String? imageUrl;
  final String? ownerName;
  final String? status; // e.g., "accepted", "rejected", "pending"
  final String? projectStatus; // e.g., "ongoing", "completed", "paused"

  // Category information
  final String? subCategoryName;

  // Instant selling fields
  final bool instantSelling;
  final String? brand;
  final String? condition; // "Brand New", "Foreign used", "Local Used", "new", "used"
  final String? salesCategory;
  final bool warranty;
  final bool delivery;

  // Marketing fields
  final bool hotSale;
  final int? discountPercent;

  const CatalogItem({
    required this.id,
    required this.title,
    required this.description,
    this.priceMin,
    this.priceMax,
    this.projectTimeline,
    this.imageUrl,
    this.ownerName,
    this.status,
    this.projectStatus,
    this.subCategoryName,
    this.instantSelling = false,
    this.brand,
    this.condition,
    this.salesCategory,
    this.warranty = false,
    this.delivery = false,
    this.hotSale = false,
    this.discountPercent,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priceMin,
        priceMax,
        projectTimeline,
        imageUrl,
        ownerName,
        status,
        projectStatus,
        subCategoryName,
        instantSelling,
        brand,
        condition,
        salesCategory,
        warranty,
        delivery,
        hotSale,
        discountPercent,
      ];
}
