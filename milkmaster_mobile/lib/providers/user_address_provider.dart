import 'package:milkmaster_mobile/models/user_address_model.dart';
import 'package:milkmaster_mobile/providers/base_provider.dart';

class UserAddressProvider extends BaseProvider<UserAddress> {
  UserAddressProvider()
      : super(
          'UserAddress',
          fromJson: (json) => UserAddress.fromJson(json),
        );
}
