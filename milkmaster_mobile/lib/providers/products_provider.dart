import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:milkmaster_mobile/models/products_model.dart';
import 'package:milkmaster_mobile/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider()
    : super("Product", fromJson: (json) => Product.fromJson(json));

  Future<List<Product>> getRecommendedProducts() async {
    isLoading = true;
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/Product/recommend"),
      headers: headers,
    );
    isLoading = false;

    if (response.statusCode == 200||response.statusCode == 201) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load recommended products");
    }
  }
}
