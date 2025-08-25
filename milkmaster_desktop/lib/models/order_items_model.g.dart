// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_items_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  id: (json['id'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  productTitle: json['productTitle'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitSize: (json['unitSize'] as num).toDouble(),
  pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'productTitle': instance.productTitle,
  'quantity': instance.quantity,
  'unitSize': instance.unitSize,
  'pricePerUnit': instance.pricePerUnit,
  'totalPrice': instance.totalPrice,
};
