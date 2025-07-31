import 'package:json_annotation/json_annotation.dart';

part 'order_status_model.g.dart';

@JsonSerializable()
class OrderStatus {
  final int id;
  final String? name;
  final String? colorCode;

  OrderStatus({
    required this.id,
    this.name,
    this.colorCode,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusToJson(this);
}
