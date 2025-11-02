import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable()
class ApiResponse {
  final bool success;
  final int statusCode;
  final dynamic data;
  final String? errorMessage;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.errorMessage,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => _$ApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}
