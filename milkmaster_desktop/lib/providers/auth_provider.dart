import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:milkmaster_desktop/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  final String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:5068',
  );

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
      final data = response.body; 
      await _storage.write(key: 'jwt', value: data);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    notifyListeners();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  //temporary
  Future<User> getUser() async {
  try {
    final token = await getToken();
    
    if (token == null) {
      return User.empty();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/Auth/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data['user']); // <- if API wraps response
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching user: $e');
  }
}

}