import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:milkmaster_mobile/models/general_search_result_model.dart';

class SearchProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  
  String get baseUrl => const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.5:5068',
  );
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  GeneralSearchResult? _searchResults;
  GeneralSearchResult? get searchResults => _searchResults;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<Map<String, String>> _getHeaders() async {
    final tokenJson = await _storage.read(key: 'jwt');
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

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = null;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/Search').replace(
        queryParameters: {'query': query},
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _searchResults = GeneralSearchResult.fromJson(data);
        _errorMessage = null;
      } else if (response.statusCode == 400) {
        _errorMessage = 'Invalid search query';
        _searchResults = null;
      } else {
        _errorMessage = 'Failed to search. Please try again.';
        _searchResults = null;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _searchResults = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = null;
    _errorMessage = null;
    notifyListeners();
  }
}
