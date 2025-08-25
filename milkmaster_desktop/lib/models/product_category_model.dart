import 'package:json_annotation/json_annotation.dart';

part 'product_category_model.g.dart';

@JsonSerializable()
class ProductCategory {
  final int id;
  final String imageUrl;
  final String name;

  ProductCategory({
    required this.id,
    required this.imageUrl,
    required this.name,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);
}

@JsonSerializable()
class ProductCategoryAdmin extends ProductCategory {
  final int count;

  ProductCategoryAdmin({
    required super.id,
    required super.imageUrl,
    required super.name,
    required this.count,
  });

  factory ProductCategoryAdmin.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryAdminFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProductCategoryAdminToJson(this);
}