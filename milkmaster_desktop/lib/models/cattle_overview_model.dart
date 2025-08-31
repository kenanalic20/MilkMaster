import 'package:json_annotation/json_annotation.dart';

part 'cattle_overview_model.g.dart';

@JsonSerializable()
class CattleOverview {
  final String? description;
  final double? weight;
  final double? height;
  final String diet;
  

  CattleOverview({
    this.description,
    required this.weight,
    required this.height,
    required this.diet
  });

  factory CattleOverview.fromJson(Map<String, dynamic> json) =>
      _$CattleOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$CattleOverviewToJson(this);
}
