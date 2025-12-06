import 'package:json_annotation/json_annotation.dart';

part 'user_address_model.g.dart';

@JsonSerializable()
class UserAddress {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  UserAddress({
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) => _$UserAddressFromJson(json);
  Map<String, dynamic> toJson() => _$UserAddressToJson(this);
}

@JsonSerializable()
class UserAddressUpdate {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  UserAddressUpdate({
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  factory UserAddressUpdate.fromJson(Map<String, dynamic> json) => _$UserAddressUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$UserAddressUpdateToJson(this);
}
