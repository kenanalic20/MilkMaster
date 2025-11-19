import 'package:json_annotation/json_annotation.dart';

part 'user_details_model.g.dart';

@JsonSerializable()
class UserDetails {
  final String? firstName;
  final String? lastName;
  final String? imageUrl;

  UserDetails({
    this.firstName,
    this.lastName,
    this.imageUrl,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => _$UserDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$UserDetailsToJson(this);
}

@JsonSerializable()
class UserDetailsUpdate {
  final String? firstName;
  final String? lastName;
  final String? imageUrl;

  UserDetailsUpdate({
    this.firstName,
    this.lastName,
    this.imageUrl,
  });

  factory UserDetailsUpdate.fromJson(Map<String, dynamic> json) => _$UserDetailsUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$UserDetailsUpdateToJson(this);
}
