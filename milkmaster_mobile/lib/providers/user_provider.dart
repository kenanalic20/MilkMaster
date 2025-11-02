import 'package:milkmaster_mobile/providers/base_provider.dart';
import 'package:milkmaster_mobile/models/user_model.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super(
    "User",
    fromJson: (json) => User.fromJson(json),
  );

}