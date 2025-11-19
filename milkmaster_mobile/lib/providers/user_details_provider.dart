import 'package:milkmaster_mobile/models/user_details_model.dart';
import 'package:milkmaster_mobile/providers/base_provider.dart';

class UserDetailsProvider extends BaseProvider<UserDetails> {
  UserDetailsProvider()
      : super(
          'UserDetail',
          fromJson: (json) => UserDetails.fromJson(json),
        );
}
