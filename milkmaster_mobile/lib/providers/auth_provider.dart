import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:milkmaster_mobile/models/user_auth_model.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  
  String get baseUrl => const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.5:5068',
  );
  
  late UserAuth? currentUser;
  
  Future<bool> login(String username, String password) async {
    print('Attempting login to: $baseUrl/Auth/login'); // Debug print
    
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: '{"username": "$username", "password": "$password"}',
    );

    if (response.statusCode == 200) {
      final data = response.body;
      await _storage.write(key: 'jwt', value: data);
      final user = await getUser();
      currentUser = user;
      notifyListeners();
      return true;
    } else {
      final data = response.body;
      print('Login failed: $data');
    }

    return false;
  }

  Future<bool> register(
    String username,
    String email,
    String password,
    String platform,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body:
          '{"username":"$username","email": "$email", "password": "$password", "platform": "$platform"}',
    );

    if (response.statusCode == 200) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    notifyListeners();
  }

  Future<String?> getToken() => _storage.read(key: 'jwt');

  Future<UserAuth> getUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        return UserAuth.empty();
      }
      final tokenData = json.decode(token);
      final jwt = tokenData['token']; 

      final response = await http.get(
        Uri.parse('$baseUrl/Auth/user'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserAuth.fromJson(data['user']); 
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }
}
