class ApiBannerModel {
  final int count;
  final String? next;
  final String? previous;
  final List<ApiBannerItem> banners;

  ApiBannerModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.banners,
  });

  factory ApiBannerModel.fromJson(Map<String, dynamic> json) {
    // Accept several shapes: {results: []} OR {data: []} OR {banners: []}
    final list = (json['results'] ?? json['data'] ?? json['banners'] ?? [])
        as List<dynamic>;
    return ApiBannerModel(
      count: json['count'] ?? (json['total'] ?? list.length) ?? 0,
      next: json['next'],
      previous: json['previous'],
      banners: list
          .map((e) => ApiBannerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': List<dynamic>.from(banners.map((x) => x.toJson())),
      };
}

class ApiBannerItem {
  final int id;
  final String title;
  final String image;
  final String category;
  final bool isActive;

  ApiBannerItem({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.isActive,
  });

  factory ApiBannerItem.fromJson(Map<String, dynamic> json) => ApiBannerItem(
        id: json["id"] ?? 0,
        title: json["title"] ?? json['name'] ?? '',
        image: json["image"] ?? json['image_url'] ?? json['banner'] ?? '',
        category: json["category"] ?? json['type'] ?? 'ArtisanHomepage',
        isActive: json["is_active"] ?? json['active'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "category": category,
        "is_active": isActive,
      };
}

enum BannerCategory { homepage, catalog, job, ads }

extension BannerCategoryExtension on BannerCategory {
  String get apiValue {
    switch (this) {
      case BannerCategory.homepage:
        return 'ArtisanHomepage';
      case BannerCategory.catalog:
        return 'ArtisanCatalog';
      case BannerCategory.job:
        return 'ArtisanJob';
      case BannerCategory.ads:
        return 'ArtisanAds';
    }
  }

  static BannerCategory fromString(String value) {
    switch (value) {
      case 'ArtisanHomepage':
        return BannerCategory.homepage;
      case 'ArtisanCatalog':
        return BannerCategory.catalog;
      case 'ArtisanJob':
        return BannerCategory.job;
      case 'ArtisanAds':
        return BannerCategory.ads;
      default:
        return BannerCategory.homepage;
    }
  }
}
