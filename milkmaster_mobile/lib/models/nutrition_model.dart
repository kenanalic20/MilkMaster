import 'package:json_annotation/json_annotation.dart';

part 'nutrition_model.g.dart';

@JsonSerializable()
class Nutrition {
  final double? energy;
  final double? fat;
  final double? carbohydrates;
  final double? protein;
  final double? salt;
  final double? calcium;

  Nutrition({
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
