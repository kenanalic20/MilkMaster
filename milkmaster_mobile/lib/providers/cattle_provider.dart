import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:milkmaster_mobile/models/cattle_model.dart';
import 'package:milkmaster_mobile/models/cattle_paginated_result.dart';
import 'package:milkmaster_mobile/providers/base_provider.dart';

class CattleProvider extends BaseProvider<Cattle> {
  CattleProvider() : super("Cattle", fromJson: (json) => Cattle.fromJson(json));
  @override
  Future<CattlePaginatedResult> fetchAll({
    Map<String, dynamic>? queryParams,
  }) async {
    isLoading = true;
    final headers = await getHeaders();
    Uri uri = Uri.parse('$baseUrl/$endPoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(
        queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    final response = await http.get(uri, headers: headers);
    isLoading = false;

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic> && decoded.containsKey('items')) {
        final itemsList =
            (decoded['items'] as List).map((json) => fromJson(json)).toList();
        items = itemsList;

        return CattlePaginatedResult(
          items: itemsList,
          totalCount: decoded['totalCount'] as int,
          totalRevenue: (decoded['totalRevenue'] as num).toDouble(),
          totalLiters: (decoded['totalLiters'] as num).toDouble(),
        );
      } else {
        throw Exception("Unexpected response format");
      }
    } else {
      throw Exception("Failed to fetch cattle");
    }
  }

  Future<void> downloadPdfToUserLocation(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200)
        throw Exception('Failed to download file');

      final fileName = url.split('/').last;
      final typeGroup = XTypeGroup(label: 'PDF', extensions: ['pdf']);
      final path = await getSavePath(
        suggestedName: fileName,
        acceptedTypeGroups: [typeGroup],
      );

      if (path == null) return;

      final file = File(path);
      await file.writeAsBytes(response.bodyBytes);

      print('File saved to $path');
    } catch (e) {
      print('Download failed: $e');
    }
  }
}
