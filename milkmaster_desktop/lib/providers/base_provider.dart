import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:milkmaster_desktop/models/paginated_result.dart';

class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String? _endPoint;
  final T Function(Map<String, dynamic>) fromJson;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<T> items = [];

  bool isLoading = false;

  BaseProvider(String endPoint, {required this.fromJson}) {
    _endPoint = endPoint;
    _baseUrl = String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'http://localhost:5068',
    );
  }

  String? get baseUrl => _baseUrl;
  String? get endPoint => _endPoint;

  Future<Map<String, String>> getHeaders() async {
    final tokenJson = await _secureStorage.read(key: 'jwt');
    String? token;

    if (tokenJson != null) {
      final Map<String, dynamic> tokenMap = json.decode(tokenJson);
      token = tokenMap['token'];
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

 Future<PaginatedResult<T>> fetchAll({Map<String, dynamic>? queryParams}) async {
  isLoading = true;

  final headers = await getHeaders();
  Uri uri = Uri.parse('$_baseUrl/$_endPoint');

  if (queryParams != null && queryParams.isNotEmpty) {
    uri = uri.replace(
      queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  final response = await http.get(uri, headers: headers);
  isLoading = false;

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);

    if (decoded is Map<String, dynamic> && decoded.containsKey('items')) {
      final itemsList = (decoded['items'] as List).map((json) => fromJson(json)).toList();
      final totalCount = decoded['totalCount'] as int;
      items = itemsList;

      return PaginatedResult(items: itemsList, totalCount: totalCount);
    } else if (decoded is List) {
      final itemsList = decoded.map((json) => fromJson(json)).toList();
      items = itemsList;
      return PaginatedResult(items: itemsList, totalCount: itemsList.length);
    } else {
      throw Exception('Unexpected response format');
    }
  } else {
    throw Exception('Failed to fetch items');
  }
}


  Future<T?> getById(String id) async {
    final headers = await getHeaders();
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
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/$_endPoint'),
      headers: headers,
      body: json.encode(body),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> update(int id, Map<String, dynamic> body) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/$_endPoint/$id'),
      headers: headers,
      body: json.encode(body),
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  Future<bool> delete(int id) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$_endPoint/$id'),
      headers: headers,
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
