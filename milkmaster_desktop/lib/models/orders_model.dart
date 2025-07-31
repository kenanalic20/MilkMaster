import 'package:json_annotation/json_annotation.dart';
import 'order_items_model.dart';
import 'order_status_model.dart';

part 'orders_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  final int id;
  final String orderNumber;
  final String customer;
  final String email;
  final String phoneNumber;
  final DateTime createdAt;
  final double total;
  final List<OrderItem> items;
  final int itemCount;
  final OrderStatus? status;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customer,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.total,
    required this.items,
    required this.itemCount,
    this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OrderCreate {
  final List<OrderItemCreate> items;

  OrderCreate({required this.items});

  factory OrderCreate.fromJson(Map<String, dynamic> json) =>
      _$OrderCreateFromJson(json);
  Map<String, dynamic> toJson() => _$OrderCreateToJson(this);
}

@JsonSerializable()
class OrderUpdate {
  final String customer;
  final String phoneNumber;
  final int statusId;

  OrderUpdate({
    required this.customer,
    required this.phoneNumber,
    required this.statusId,
  });

  factory OrderUpdate.fromJson(Map<String, dynamic> json) =>
      _$OrderUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$OrderUpdateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OrderSeeder {
  final String userId;
  final String orderNumber;
  final String customer;
  final String email;
  final String phoneNumber;
  final DateTime createdAt;
  final double total;
  final int itemCount;
  final int statusId;
  final List<OrderItemCreate> items;

  OrderSeeder({
    required this.userId,
    required this.orderNumber,
    required this.customer,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.total,
    required this.itemCount,
    required this.statusId,
    required this.items,
  });

  factory OrderSeeder.fromJson(Map<String, dynamic> json) =>
      _$OrderSeederFromJson(json);
  Map<String, dynamic> toJson() => _$OrderSeederToJson(this);
}
