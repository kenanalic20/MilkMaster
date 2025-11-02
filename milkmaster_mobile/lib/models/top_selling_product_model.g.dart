// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_selling_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopSellingProduct _$TopSellingProductFromJson(Map<String, dynamic> json) =>
    TopSellingProduct(
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      totalSales: (json['totalSales'] as num).toDouble(),
    );

Map<String, dynamic> _$TopSellingProductToJson(TopSellingProduct instance) =>
    <String, dynamic>{
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'totalSales': instance.totalSales,
    };
