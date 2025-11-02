import 'package:milkmaster_mobile/models/order_status_model.dart';
import 'package:milkmaster_mobile/providers/base_provider.dart';

class OrderStatusProvider extends BaseProvider<OrderStatus> {
  OrderStatusProvider() : super(
    "OrderStatus",
    fromJson: (json) => OrderStatus.fromJson(json),
  );
}
