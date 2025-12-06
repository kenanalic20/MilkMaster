// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breeding_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreedingStatus _$BreedingStatusFromJson(Map<String, dynamic> json) =>
    BreedingStatus(
      pragnancyStatus: json['pragnancyStatus'] as bool,
      lastCalving: DateTime.parse(json['lastCalving'] as String),
      numberOfCalves: (json['numberOfCalves'] as num).toInt(),
    );

Map<String, dynamic> _$BreedingStatusToJson(BreedingStatus instance) =>
    <String, dynamic>{
      'pragnancyStatus': instance.pragnancyStatus,
      'lastCalving': instance.lastCalving.toIso8601String(),
      'numberOfCalves': instance.numberOfCalves,
    };
