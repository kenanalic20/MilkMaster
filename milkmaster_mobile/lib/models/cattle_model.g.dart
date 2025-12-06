// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cattle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cattle _$CattleFromJson(Map<String, dynamic> json) => Cattle(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String,
  milkCartonUrl: json['milkCartonUrl'] as String,
  tagNumber: json['tagNumber'] as String,
  cattleCategory:
      json['cattleCategory'] == null
          ? null
          : CattleCategory.fromJson(
            json['cattleCategory'] as Map<String, dynamic>,
          ),
  breedOfCattle: json['breedOfCattle'] as String?,
  age: (json['age'] as num).toInt(),
  litersPerDay: (json['litersPerDay'] as num).toDouble(),
  monthlyValue: (json['monthlyValue'] as num).toDouble(),
  birthDate: DateTime.parse(json['birthDate'] as String),
  healthCheck: DateTime.parse(json['healthCheck'] as String),
  overview:
      json['overview'] == null
          ? null
          : CattleOverview.fromJson(json['overview'] as Map<String, dynamic>),
  breedingStatus:
      json['breedingStatus'] == null
          ? null
          : BreedingStatus.fromJson(
            json['breedingStatus'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$CattleToJson(Cattle instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'milkCartonUrl': instance.milkCartonUrl,
  'tagNumber': instance.tagNumber,
  'cattleCategory': instance.cattleCategory?.toJson(),
  'breedOfCattle': instance.breedOfCattle,
  'age': instance.age,
  'litersPerDay': instance.litersPerDay,
  'monthlyValue': instance.monthlyValue,
  'birthDate': instance.birthDate.toIso8601String(),
  'healthCheck': instance.healthCheck.toIso8601String(),
  'overview': instance.overview?.toJson(),
  'breedingStatus': instance.breedingStatus?.toJson(),
};
