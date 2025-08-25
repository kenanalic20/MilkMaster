// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cattle_overview_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CattleOverview _$CattleOverviewFromJson(Map<String, dynamic> json) =>
    CattleOverview(
      description: json['description'] as String?,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      diet: json['diet'] as String,
    );

Map<String, dynamic> _$CattleOverviewToJson(CattleOverview instance) =>
    <String, dynamic>{
      'description': instance.description,
      'weight': instance.weight,
      'height': instance.height,
      'diet': instance.diet,
    };
