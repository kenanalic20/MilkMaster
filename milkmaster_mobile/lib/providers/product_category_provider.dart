import 'package:milkmaster_mobile/models/product_category_model.dart';
import 'package:milkmaster_mobile/providers/base_provider.dart';

class ProductCategoryProvider extends BaseProvider<ProductCategory> {
  ProductCategoryProvider() : super(
    "ProductCategories",
    fromJson: (json) => ProductCategory.fromJson(json),
  );

}
