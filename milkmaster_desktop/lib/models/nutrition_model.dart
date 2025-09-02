import 'package:json_annotation/json_annotation.dart';

part 'nutrition_model.g.dart';

@JsonSerializable()
class Nutrition {
  final int id;
  final int productId;
  final double? energy;
  final double? fat;
  final double? carbohydrates;
  final double? protein;
  final double? salt;
  final double? calcium;

  Nutrition({
    required this.id,
    required this.productId,
    this.energy,
    this.fat,
    this.carbohydrates,
    this.protein,
    this.salt,
    this.calcium,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) =>
      _$NutritionFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionToJson(this);
}
