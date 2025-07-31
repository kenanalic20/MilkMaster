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

OrderCreate _$OrderCreateFromJson(Map<String, dynamic> json) => OrderCreate(
  items:
      (json['items'] as List<dynamic>)
          .map((e) => OrderItemCreate.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$OrderCreateToJson(OrderCreate instance) =>
    <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};

OrderUpdate _$OrderUpdateFromJson(Map<String, dynamic> json) => OrderUpdate(
  customer: json['customer'] as String,
  phoneNumber: json['phoneNumber'] as String,
  statusId: (json['statusId'] as num).toInt(),
);

Map<String, dynamic> _$OrderUpdateToJson(OrderUpdate instance) =>
    <String, dynamic>{
      'customer': instance.customer,
      'phoneNumber': instance.phoneNumber,
      'statusId': instance.statusId,
    };

OrderSeeder _$OrderSeederFromJson(Map<String, dynamic> json) => OrderSeeder(
  userId: json['userId'] as String,
  orderNumber: json['orderNumber'] as String,
  customer: json['customer'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  total: (json['total'] as num).toDouble(),
  itemCount: (json['itemCount'] as num).toInt(),
  statusId: (json['statusId'] as num).toInt(),
  items:
      (json['items'] as List<dynamic>)
          .map((e) => OrderItemCreate.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$OrderSeederToJson(OrderSeeder instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'orderNumber': instance.orderNumber,
      'customer': instance.customer,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'createdAt': instance.createdAt.toIso8601String(),
      'total': instance.total,
      'itemCount': instance.itemCount,
      'statusId': instance.statusId,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
