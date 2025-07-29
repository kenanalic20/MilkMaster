import 'package:milkmaster_desktop/models/products_model.dart';
import 'package:milkmaster_desktop/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super(
    "Product",
    fromJson: (json) => Product.fromJson(json),
  );

}
