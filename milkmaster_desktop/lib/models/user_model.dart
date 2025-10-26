import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String? id;
  final String? userName;
  final String? customerName;
  final String? email;
  final String? phoneNumber;
  final int orderCount;
  final DateTime? lastOrderDate;
  final String? street;
  final String? imageUrl;

  User({
    this.id,
    this.userName,
    this.customerName,
    this.email,
    this.phoneNumber,
    this.orderCount = 0,
    this.lastOrderDate,
    this.street,
    this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
