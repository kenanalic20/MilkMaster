// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num).toInt(),
  imageUrl: json['imageUrl'] as String,
  title: json['title'] as String,
  pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
  unit:
      json['unit'] == null
          ? null
          : Unit.fromJson(json['unit'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toInt(),
  description: json['description'] as String?,
  productCategories:
      (json['productCategories'] as List<dynamic>?)
          ?.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
  cattleCategory:
      json['cattleCategory'] == null
          ? null
          : CattleCategory.fromJson(
            json['cattleCategory'] as Map<String, dynamic>,
          ),
  nutrition:
      json['nutrition'] == null
          ? null
          : Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'title': instance.title,
  'pricePerUnit': instance.pricePerUnit,
  'unit': instance.unit?.toJson(),
  'quantity': instance.quantity,
  'description': instance.description,
  'productCategories':
      instance.productCategories?.map((e) => e.toJson()).toList(),
  'cattleCategory': instance.cattleCategory?.toJson(),
  'nutrition': instance.nutrition?.toJson(),
};
