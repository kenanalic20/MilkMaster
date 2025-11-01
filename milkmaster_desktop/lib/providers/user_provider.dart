import 'package:milkmaster_desktop/providers/base_provider.dart';
import 'package:milkmaster_desktop/models/user_model.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super(
    "User",
    fromJson: (json) => User.fromJson(json),
  );

}