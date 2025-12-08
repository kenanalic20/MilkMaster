import 'package:milkmaster_mobile/providers/base_provider.dart';
import 'package:milkmaster_mobile/models/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<User> {
  UserProvider() : super(
    "User",
    fromJson: (json) => User.fromJson(json),
  );

  Future<bool> updateEmail(String userId, String email) async {
    try {
      final headers = await getHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/User/$userId/email'),
        headers: headers,
        body: json.encode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating email: $e');
      return false;
    }
  }

  Future<bool> updatePhoneNumber(String userId, String phoneNumber) async {
    try {
      final headers = await getHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/User/$userId/phone'),
        headers: headers,
        body: json.encode({'phoneNumber': phoneNumber}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating phone number: $e');
      return false;
    }
  }

}