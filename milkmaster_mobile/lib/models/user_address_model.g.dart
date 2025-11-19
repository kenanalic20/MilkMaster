// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAddress _$UserAddressFromJson(Map<String, dynamic> json) => UserAddress(
  street: json['street'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['zipCode'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$UserAddressToJson(UserAddress instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'zipCode': instance.zipCode,
      'country': instance.country,
    };

UserAddressUpdate _$UserAddressUpdateFromJson(Map<String, dynamic> json) =>
    UserAddressUpdate(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$UserAddressUpdateToJson(UserAddressUpdate instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'zipCode': instance.zipCode,
      'country': instance.country,
    };
