import 'package:milkmaster_mobile/models/api_response.dart';
import 'package:milkmaster_mobile/models/orders_model.dart';
import 'package:milkmaster_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class OrdersProvider extends BaseProvider<Order> {
  OrdersProvider() : super(
    "Orders",
    fromJson: (json) => Order.fromJson(json),
  );

  Future<ApiResponse> checkout(List<Map<String, dynamic>> items) async {
    final body = {
      'items': items,
    };
    
    return await create(body); 
  }

   Future<double> getTotalRevenue() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/Orders/total-revenue"),
      headers: headers
    );
    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception("Failed to load top selling products");
    }
  }
}
