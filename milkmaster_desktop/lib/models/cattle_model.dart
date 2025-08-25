import 'package:json_annotation/json_annotation.dart';
import 'package:milkmaster_desktop/models/breeding_status_model.dart';
import 'package:milkmaster_desktop/models/cattle_category_model.dart';
import 'package:milkmaster_desktop/models/cattle_overview_model.dart';

part 'cattle_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Cattle {
  final int id;
  final String name;
  final String imageUrl;
  final String milkCartonUrl;
  final String tagNumber;
  final CattleCategory cattleCategory;
  final String? breedOfCattle;
  final int age;
  final double litersPerDay;
  final double monthlyValue;
  final DateTime birthDate;
  final DateTime healthCheck;
  final CattleOverview? overview;
  final BreedingStatus? breedingStatus;

  Cattle({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.milkCartonUrl,
    required this.tagNumber,
    required this.cattleCategory,
    this.breedOfCattle,
    required this.age,
    required this.litersPerDay,
    required this.monthlyValue,
    required this.birthDate,
    required this.healthCheck,
    this.overview,
    this.breedingStatus,
  });

  factory Cattle.fromJson(Map<String, dynamic> json) =>
      _$CattleFromJson(json);

  Map<String, dynamic> toJson() => _$CattleToJson(this);
}
