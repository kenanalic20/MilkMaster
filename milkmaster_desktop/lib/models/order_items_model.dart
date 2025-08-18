import 'package:json_annotation/json_annotation.dart';

part 'order_items_model.g.dart';

@JsonSerializable()
class OrderItem {
  final int id;
  final int productId;
  final String productTitle;
  final int quantity;
  final double unitSize;
  final double pricePerUnit;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.quantity,
    required this.unitSize,
    required this.pricePerUnit,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable()
class OrderItemCreate {
  final int productId;
  final int quantity;
  final double unitSize;

  OrderItemCreate({
    required this.productId,
    required this.quantity,
    required this.unitSize,
  });

  factory OrderItemCreate.fromJson(Map<String, dynamic> json) =>
      _$OrderItemCreateFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemCreateToJson(this);
}

@JsonSerializable()
class OrderItemUpdate {
  final int quantity;
  final double unitSize;
  final double pricePerUnit;

  OrderItemUpdate({
    required this.quantity,
    required this.unitSize,
    required this.pricePerUnit,
  });

  factory OrderItemUpdate.fromJson(Map<String, dynamic> json) =>
      _$OrderItemUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemUpdateToJson(this);
}
