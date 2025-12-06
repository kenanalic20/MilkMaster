import 'package:json_annotation/json_annotation.dart';
import 'package:milkmaster_mobile/models/cattle_category_model.dart';
import 'package:milkmaster_mobile/models/nutrition_model.dart';
import 'package:milkmaster_mobile/models/product_category_model.dart';
import 'package:milkmaster_mobile/models/unit_model.dart';

part 'products_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Product {
  final int id;
  final String imageUrl;
  final String title;
  final double pricePerUnit;
  final Unit? unit;
  final int quantity;
  final String? description;
  final List<ProductCategory>? productCategories;
  final CattleCategory? cattleCategory;
  final Nutrition? nutrition;

  Product({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.pricePerUnit,
    this.unit,
    required this.quantity,
    this.description,
    this.productCategories,
    this.cattleCategory,
    this.nutrition,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
