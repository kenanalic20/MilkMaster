// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Nutrition _$NutritionFromJson(Map<String, dynamic> json) => Nutrition(
  id: (json['id'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  energy: (json['energy'] as num?)?.toDouble(),
  fat: (json['fat'] as num?)?.toDouble(),
  carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
  protein: (json['protein'] as num?)?.toDouble(),
  salt: (json['salt'] as num?)?.toDouble(),
  calcium: (json['calcium'] as num?)?.toDouble(),
);

Map<String, dynamic> _$NutritionToJson(Nutrition instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'energy': instance.energy,
  'fat': instance.fat,
  'carbohydrates': instance.carbohydrates,
  'protein': instance.protein,
  'salt': instance.salt,
  'calcium': instance.calcium,
};
