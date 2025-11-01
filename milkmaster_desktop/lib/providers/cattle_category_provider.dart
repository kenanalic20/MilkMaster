import 'package:milkmaster_desktop/models/cattle_category_model.dart';
import 'package:milkmaster_desktop/providers/base_provider.dart';

class CattleCategoryProvider extends BaseProvider<CattleCategory> {
  CattleCategoryProvider() : super(
    "CattleCategories",
    fromJson: (json) => CattleCategory.fromJson(json),
  );

}
