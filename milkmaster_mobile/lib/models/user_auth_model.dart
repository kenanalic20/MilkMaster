class UserAuth {
  final String id;
  final String userName;
  final String email;
  final String? phoneNumber;
  final List<String> roles;

  UserAuth({
    required this.id,
    required this.userName,
    required this.email,
    this.phoneNumber,
    required this.roles,
  });

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'] as String?,
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'roles': roles,
    };
  }

  static Future<UserAuth> empty() {
    return Future.value(UserAuth(
      id: '',
      userName: '',
      email: '',
      phoneNumber: null,
      roles: [],
    ));
  }
}
