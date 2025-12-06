import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:milkmaster_mobile/models/file_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FileProvider with ChangeNotifier {
  final String _baseUrl;
  final _secureStorage = const FlutterSecureStorage(); 

  FileProvider({String? baseUrl})
      : _baseUrl = baseUrl ?? const String.fromEnvironment(
          'BASE_URL',
          defaultValue: 'http://192.168.1.5:5068',
        );

  final String _endpoint = 'File';

  Future<Map<String, String>> _getHeaders() async {
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

  Future<String?> uploadFile(FileModel model) async {
    if (model.file == null) return null;

    final uri = Uri.parse('$_baseUrl/$_endpoint');
    final request = http.MultipartRequest('POST', uri)
      ..fields['Subfolder'] = model.subfolder
      ..files.add(
        await http.MultipartFile.fromPath(
          'File',
          model.file!.path,
          contentType: MediaType('application', 'octet-stream'),
        ),
      );

    request.headers.addAll(await _getHeaders());

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final fileUrl = json.decode(responseBody.body)['fileUrl'];
      notifyListeners();
      return fileUrl;
    } else {
      throw Exception('File upload failed: ${responseBody.body}');
    }
  }

  Future<String?> updateFile(FileUpdateModel model) async {
    if (model.file == null || model.oldFileUrl == null) return null;

    final uri = Uri.parse('$_baseUrl/$_endpoint/update');
    final request = http.MultipartRequest('PUT', uri)
      ..fields['Subfolder'] = model.subfolder
      ..fields['OldFileUrl'] = model.oldFileUrl!
      ..files.add(
        await http.MultipartFile.fromPath(
          'File',
          model.file!.path,
          contentType: MediaType('application', 'octet-stream'),
        ),
      );

    request.headers.addAll(await _getHeaders());

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final fileUrl = json.decode(responseBody.body)['fileUrl'];
      notifyListeners();
      return fileUrl;
    } else {
      throw Exception('File update failed: ${responseBody.statusCode}');
    }
  }

  Future<bool> deleteFile(FileDeleteModel model) async {
    final uri = Uri.parse('$_baseUrl/$_endpoint/delete');
    final request = http.MultipartRequest('DELETE', uri)
      ..fields['FileUrl'] = model.fileUrl
      ..fields['Subfolder'] = model.subfolder;

    request.headers.addAll(await _getHeaders());

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      notifyListeners();
      return true;
    } else {
      throw Exception('File delete failed: ${responseBody.body}');
    }
  }
}
