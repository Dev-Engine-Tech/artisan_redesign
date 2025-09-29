import 'package:equatable/equatable.dart';

/// Entity representing a catalog item/product
class Catalog extends Equatable {
  final int id;
  final String title;
  final String description;
  final List<String> pictures;

  const Catalog({
    required this.id,
    required this.title,
    required this.description,
    required this.pictures,
  });

  /// Get the primary image for the catalog
  String get primaryImage => pictures.isNotEmpty ? pictures.first : '';

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    pictures,
  ];

  Catalog copyWith({
    int? id,
    String? title,
    String? description,
    List<String>? pictures,
  }) {
    return Catalog(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pictures: pictures ?? this.pictures,
    );
  }
}