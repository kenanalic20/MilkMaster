// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cattle_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CattleCategory _$CattleCategoryFromJson(Map<String, dynamic> json) =>
    CattleCategory(
      id: (json['id'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$CattleCategoryToJson(CattleCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'name': instance.name,
      'title': instance.title,
      'description': instance.description,
    };
