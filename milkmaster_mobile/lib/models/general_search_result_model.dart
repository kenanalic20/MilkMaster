import 'package:json_annotation/json_annotation.dart';
import 'package:milkmaster_mobile/models/cattle_model.dart';
import 'package:milkmaster_mobile/models/products_model.dart';

part 'general_search_result_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GeneralSearchResult {
  final List<Product> products;
  final List<Cattle> cattles;

  GeneralSearchResult({
    required this.products,
    required this.cattles,
  });

  factory GeneralSearchResult.fromJson(Map<String, dynamic> json) =>
      _$GeneralSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralSearchResultToJson(this);
}
