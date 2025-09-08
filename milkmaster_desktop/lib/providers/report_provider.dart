import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/models/orders_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ReportProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static String? _baseUrl;
  String? _endPoint;

  ReportProvider(String endPoint) {
    _endPoint = endPoint;
    _baseUrl = String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'http://localhost:5068',
    );
  }
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

  Future<Uint8List> fetchFile({Map<String, dynamic>? body}) async {
    final headers = await getHeaders();
    final url = '$_baseUrl/$_endPoint';

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to fetch file. Status code: ${response.statusCode}');
    }
  }

 Future<void> downloadPdfToUserLocation({Map<String, dynamic>? body}) async {
    try {
      final bytes = await fetchFile(body: body);
      final fileName = 'report.pdf';

      final typeGroup = XTypeGroup(label: 'PDF', extensions: ['pdf']);
      final path = await getSavePath(
        suggestedName: fileName,
        acceptedTypeGroups: [typeGroup],
      );

      if (path == null) return;

      final file = File(path);
      await file.writeAsBytes(bytes);

      print('Report saved to $path');
    } catch (e) {
      print('Download failed: $e');
    }
  }
}
