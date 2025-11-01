// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) => ApiResponse(
  success: json['success'] as bool,
  statusCode: (json['statusCode'] as num).toInt(),
  data: json['data'],
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$ApiResponseToJson(ApiResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'data': instance.data,
      'errorMessage': instance.errorMessage,
    };
