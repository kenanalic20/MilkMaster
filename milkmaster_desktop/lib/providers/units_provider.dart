import 'package:milkmaster_desktop/models/unit_model.dart';
import 'package:milkmaster_desktop/providers/base_provider.dart';

class UnitsProvider extends BaseProvider<Unit> {
  UnitsProvider() : super(
    "Units",
    fromJson: (json) => Unit.fromJson(json),
  );

}
