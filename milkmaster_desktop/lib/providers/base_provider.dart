import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String? _endPoint;
  final T Function(Map<String, dynamic>) fromJson;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  List<T> items = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BaseProvider(String endPoint, {required this.fromJson}) {
    _endPoint = endPoint;
    _baseUrl = String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'http://localhost:5068',
    );
  }

  Future<Map<String, String>> _getHeaders() async {
    final tokenJson = await _secureStorage.read(key: 'jwt');
    String? token;

    if (tokenJson != null) {
      final Map<String, dynamic> tokenMap = json.decode(tokenJson);
      token = tokenMap['token'];
    }
    print('Token: $token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchAll({Map<String, dynamic>? queryParams}) async {
    _isLoading = true;
    final headers = await _getHeaders();
    Uri uri = Uri.parse('$_baseUrl/$_endPoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          ...queryParams.map((key, value) => MapEntry(key, value.toString())),
        },
      );
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);

      // ✅ Extract the actual list of items
      final List<dynamic> data = jsonMap['items'];

      items = data.map((json) => fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to fetch items');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<T?> getById(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/$_endPoint/$id'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return fromJson(data);
    } else {
      return null;
    }
  }

  Future<bool> create(Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/$_endPoint'),
      headers: headers,
      body: json.encode(body),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> update(String id, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/$_endPoint/$id'),
      headers: headers,
      body: json.encode(body),
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  Future<bool> delete(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$_endPoint/$id'),
      headers: headers,
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
