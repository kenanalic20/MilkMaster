import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  
  String get baseUrl => const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.5:5068',
  );

  Future<Map<String, String>> getHeaders() async {
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

  Future<String?> getPublishableKey() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Payment/config'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['publishableKey'];
      }
      return null;
    } catch (e) {
      print('Error getting publishable key: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    String currency = 'usd',
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/Payment/create-payment-intent'),
        headers: headers,
        body: json.encode({
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error creating payment intent: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  Future<bool> confirmPayment(String paymentIntentId) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/Payment/confirm-payment'),
        headers: headers,
        body: json.encode({
          'paymentIntentId': paymentIntentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error confirming payment: $e');
      return false;
    }
  }
}
