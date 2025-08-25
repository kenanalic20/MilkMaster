import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:milkmaster_desktop/models/cattle_model.dart';
import 'package:milkmaster_desktop/models/cattle_paginated_result.dart';
import 'package:milkmaster_desktop/providers/base_provider.dart';

class CattleProvider extends BaseProvider<Cattle> {
  CattleProvider() : super(
    "Cattle",
    fromJson: (json) => Cattle.fromJson(json),
  );
  @override
  Future<CattlePaginatedResult> fetchAll({Map<String, dynamic>? queryParams}) async {
    isLoading = true;                       
    final headers = await getHeaders();      
    Uri uri = Uri.parse('$baseUrl/$endPoint');

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
  

}
