import 'package:json_annotation/json_annotation.dart';

part 'breeding_status_model.g.dart';

@JsonSerializable()
class BreedingStatus {
  final bool pragnancyStatus;
  final DateTime lastCalving;
  final int numberOfCalves;

  BreedingStatus({
    required this.pragnancyStatus,
    required this.lastCalving,
    required this.numberOfCalves
  });

  factory BreedingStatus.fromJson(Map<String, dynamic> json) =>
      _$BreedingStatusFromJson(json);

  Map<String, dynamic> toJson() => _$BreedingStatusToJson(this);
}
