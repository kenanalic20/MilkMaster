import 'package:milkmaster_desktop/models/orders_model.dart';
import 'package:milkmaster_desktop/providers/base_provider.dart';

class OrdersProvider extends BaseProvider<Order> {
  OrdersProvider() : super(
    "Orders",
    fromJson: (json) => Order.fromJson(json),
  );

}
