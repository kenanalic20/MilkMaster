import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:milkmaster_desktop/costants/api_costants.dart';

class AuthProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  final String baseUrl = ApiConstants.baseUrl;

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: '{"username": "$username", "password": "$password"}',
    );

    if (response.statusCode == 200) {
      final data = response.body;
      await _storage.write(key: 'jwt', value: data);
      notifyListeners();
      print('Login successful: $data');
      return true;
    }
    else{
      final data = response.body;
      print('Login failed: $data');
    }

    
    return false;
  }

  Future<bool> register(String username,String email, String password, String platform) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: '{"username":"$username","email": "$email", "password": "$password", "platform": "$platform"}',
    );

    if (response.statusCode == 200) {
      final data = response.body; // Assuming the token is in the response body
      await _storage.write(key: 'jwt', value: data);
      notifyListeners();
      print('Registration successful: $data');
      return true;
    }
    
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

}