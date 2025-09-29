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

  factory ApiBannerModel.fromJson(Map<String, dynamic> json) => ApiBannerModel(
        count: json["count"] ?? 0,
        next: json["next"],
        previous: json["previous"],
        banners: List<ApiBannerItem>.from(
          (json["results"] ?? []).map((x) => ApiBannerItem.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": List<dynamic>.from(banners.map((x) => x.toJson())),
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
        title: json["title"] ?? '',
        image: json["image"] ?? '',
        category: json["category"] ?? 'ArtisanHomepage',
        isActive: json["is_active"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "category": category,
        "is_active": isActive,
      };
}

enum BannerCategory { 
  homepage, 
  catalog, 
  job, 
  ads 
}

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