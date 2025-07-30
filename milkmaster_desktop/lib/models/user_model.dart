class User {
  final String id;
  final String userName;
  final String email;
  final String? phoneNumber;
  final List<String> roles;

  User({
    required this.id,
    required this.userName,
    required this.email,
    this.phoneNumber,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

  static Future<User> empty() {
    return Future.value(User(
      id: '',
      userName: '',
      email: '',
      phoneNumber: null,
      roles: [],
    ));
  }
}
