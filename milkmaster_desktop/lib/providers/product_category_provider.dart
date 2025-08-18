import 'package:milkmaster_desktop/models/product_category_model.dart';
import 'package:milkmaster_desktop/providers/base_provider.dart';

class ProductCategoryProvider extends BaseProvider<ProductCategoryAdmin> {
  ProductCategoryProvider() : super(
    "ProductCategories",
    fromJson: (json) => ProductCategoryAdmin.fromJson(json),
  );

}
