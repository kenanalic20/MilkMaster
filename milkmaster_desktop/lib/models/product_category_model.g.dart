// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductCategory _$ProductCategoryFromJson(Map<String, dynamic> json) =>
    ProductCategory(
      id: (json['id'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$ProductCategoryToJson(ProductCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'name': instance.name,
    };

ProductCategoryAdmin _$ProductCategoryAdminFromJson(
  Map<String, dynamic> json,
) => ProductCategoryAdmin(
  id: (json['id'] as num).toInt(),
  imageUrl: json['imageUrl'] as String,
  name: json['name'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$ProductCategoryAdminToJson(
  ProductCategoryAdmin instance,
) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'name': instance.name,
  'count': instance.count,
};
