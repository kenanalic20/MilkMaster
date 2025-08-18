import 'package:json_annotation/json_annotation.dart';

part 'cattle_category_model.g.dart';

@JsonSerializable()
class CattleCategory {
  final int id;
  final String imageUrl;
  final String name;
  final String title;
  final String description;

  CattleCategory({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.title,
    required this.description,
  });

  factory CattleCategory.fromJson(Map<String, dynamic> json) =>
      _$CattleCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CattleCategoryToJson(this);
}

@JsonSerializable()
class CattleCategoryCreate {
  final String imageUrl;
  final String title;
  final String name;
  final String description;

  CattleCategoryCreate({
    required this.imageUrl,
    required this.title,
    required this.name,
    required this.description,
  });

  factory CattleCategoryCreate.fromJson(Map<String, dynamic> json) =>
      _$CattleCategoryCreateFromJson(json);

  Map<String, dynamic> toJson() => _$CattleCategoryCreateToJson(this);
}

@JsonSerializable()
class CattleCategoryUpdate {
  final String imageUrl;
  final String name;
  final String title;
  final String description;

  CattleCategoryUpdate({
    required this.imageUrl,
    required this.name,
    required this.title,
    required this.description,
  });

  factory CattleCategoryUpdate.fromJson(Map<String, dynamic> json) =>
      _$CattleCategoryUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$CattleCategoryUpdateToJson(this);
}
