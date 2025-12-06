import 'package:milkmaster_mobile/models/settings_model.dart';
import 'package:milkmaster_mobile/providers/base_provider.dart';

class SettingsProvider extends BaseProvider<Settings> {
  SettingsProvider()
      : super(
          'Settings',
          fromJson: (json) => Settings.fromJson(json),
        );
}
