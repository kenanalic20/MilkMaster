import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:milkmaster_desktop/models/products_model.dart';
import 'package:milkmaster_desktop/models/top_selling_product_model.dart';
import 'package:milkmaster_desktop/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider()
    : super("Product", fromJson: (json) => Product.fromJson(json));

  Future<List<TopSellingProduct>> getTopSellingProducts({int count = 4}) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/Product/top-selling?count=$count"),
      headers: headers
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => TopSellingProduct.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load top selling products");
    }
  }
  Future<int> getSoldProductCount() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/Product/sold-products-count"),
      headers: headers
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception("Failed to load top selling products");
    }
  }
}
