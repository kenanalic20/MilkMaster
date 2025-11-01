import 'package:json_annotation/json_annotation.dart';

part 'top_selling_product_model.g.dart';

@JsonSerializable()
class TopSellingProduct {
  final String title;
  final String imageUrl;
  final double totalSales;

  TopSellingProduct({
    required this.title,
    required this.imageUrl,
    required this.totalSales,
  });

  factory TopSellingProduct.fromJson(Map<String, dynamic> json) =>
      _$TopSellingProductFromJson(json);
  Map<String, dynamic> toJson() => _$TopSellingProductToJson(this);
}
