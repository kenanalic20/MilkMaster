import 'package:http/http.dart' as http;
import 'package:milkmaster_desktop/models/order_status_model.dart';
import 'package:milkmaster_desktop/providers/base_provider.dart';

class OrderStatusProvider extends BaseProvider<OrderStatus> {
  OrderStatusProvider() : super(
    "OrderStatus",
    fromJson: (json) => OrderStatus.fromJson(json),
  );
}
