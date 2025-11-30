// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_search_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneralSearchResult _$GeneralSearchResultFromJson(Map<String, dynamic> json) =>
    GeneralSearchResult(
      products: (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      cattles: (json['cattles'] as List<dynamic>)
          .map((e) => Cattle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GeneralSearchResultToJson(
        GeneralSearchResult instance) =>
    <String, dynamic>{
      'products': instance.products.map((e) => e.toJson()).toList(),
      'cattles': instance.cattles.map((e) => e.toJson()).toList(),
    };
