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
