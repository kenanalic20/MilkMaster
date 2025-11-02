// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num).toInt(),
  orderNumber: json['orderNumber'] as String,
  customer: json['customer'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  total: (json['total'] as num).toDouble(),
  items:
      (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  itemCount: (json['itemCount'] as num).toInt(),
  status:
      json['status'] == null
          ? null
          : OrderStatus.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'orderNumber': instance.orderNumber,
  'customer': instance.customer,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'createdAt': instance.createdAt.toIso8601String(),
  'total': instance.total,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'itemCount': instance.itemCount,
  'status': instance.status?.toJson(),
};
