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
  quantity: (json['quantity'] as num).toInt(),
  description: json['description'] as String?,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'title': instance.title,
  'pricePerUnit': instance.pricePerUnit,
  'quantity': instance.quantity,
  'description': instance.description,
};

ProductCreate _$ProductCreateFromJson(Map<String, dynamic> json) =>
    ProductCreate(
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      unitId: (json['unitId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      description: json['description'] as String?,
      productCategories:
          (json['productCategories'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      cattleCategoryId: (json['cattleCategoryId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductCreateToJson(ProductCreate instance) =>
    <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'title': instance.title,
      'pricePerUnit': instance.pricePerUnit,
      'unitId': instance.unitId,
      'quantity': instance.quantity,
      'description': instance.description,
      'productCategories': instance.productCategories,
      'cattleCategoryId': instance.cattleCategoryId,
    };

ProductUpdate _$ProductUpdateFromJson(Map<String, dynamic> json) =>
    ProductUpdate(
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      unitId: (json['unitId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      description: json['description'] as String?,
      productCategories:
          (json['productCategories'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      cattleCategoryId: (json['cattleCategoryId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductUpdateToJson(ProductUpdate instance) =>
    <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'title': instance.title,
      'pricePerUnit': instance.pricePerUnit,
      'unitId': instance.unitId,
      'quantity': instance.quantity,
      'description': instance.description,
      'productCategories': instance.productCategories,
      'cattleCategoryId': instance.cattleCategoryId,
    };
