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
        projectStatus
      ];
}
