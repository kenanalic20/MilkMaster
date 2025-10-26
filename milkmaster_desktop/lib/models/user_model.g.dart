// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  userName: json['userName'] as String?,
  customerName: json['customerName'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
  lastOrderDate:
      json['lastOrderDate'] == null
          ? null
          : DateTime.parse(json['lastOrderDate'] as String),
  street: json['street'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'userName': instance.userName,
  'customerName': instance.customerName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'orderCount': instance.orderCount,
  'lastOrderDate': instance.lastOrderDate?.toIso8601String(),
  'street': instance.street,
  'imageUrl': instance.imageUrl,
};
