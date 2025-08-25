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
