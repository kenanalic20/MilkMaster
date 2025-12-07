import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:milkmaster_mobile/main.dart';
import 'package:milkmaster_mobile/providers/auth_provider.dart';
import 'package:milkmaster_mobile/providers/cart_provider.dart';
import 'package:milkmaster_mobile/providers/notification_settings_provider.dart';
import 'package:milkmaster_mobile/providers/settings_provider.dart';
import 'package:milkmaster_mobile/providers/user_address_provider.dart';
import 'package:milkmaster_mobile/providers/user_details_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _personalFormKey = GlobalKey<FormBuilderState>();
  final _addressFormKey = GlobalKey<FormBuilderState>();

  bool _emailNotifications = false;
  bool _pushNotifications = false;

  String? userId;
  bool isLoading = true;
  String displayName = 'John Doe';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = await authProvider.getUser();
      userId = user.id;

      final userDetailsProvider =
          Provider.of<UserDetailsProvider>(context, listen: false);
      final userDetails = await userDetailsProvider.getById(userId!);

      final userAddressProvider =
          Provider.of<UserAddressProvider>(context, listen: false);
      final userAddress = await userAddressProvider.getById(userId!);

      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final settings = await settingsProvider.getById(userId!);

      if (mounted) {
        setState(() {
          if (userDetails != null) {
            final firstName = userDetails.firstName ?? '';
            final lastName = userDetails.lastName ?? '';
            displayName = '$firstName $lastName'.trim().isEmpty
                ? user.userName
                : '$firstName $lastName';
          } else {
            displayName = user.userName;
          }

          if (settings != null) {
            _emailNotifications = settings.notificationsEnabled;
            _pushNotifications = settings.pushNotificationsEnabled;
          }
        });

        _personalFormKey.currentState?.patchValue({
          'firstName': userDetails?.firstName ?? '',
          'lastName': userDetails?.lastName ?? '',
          'email': user.email,
          'phone': user.phoneNumber ?? '',
        });

        _addressFormKey.currentState?.patchValue({
          'street': userAddress?.street ?? '',
          'city': userAddress?.city ?? '',
          'state': userAddress?.state ?? '',
          'zipCode': userAddress?.zipCode ?? '',
          'country': userAddress?.country ?? '',
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _savePersonalInfo() async {
    if (_personalFormKey.currentState?.saveAndValidate() ?? false) {
      if (userId == null) return;

      try {
        final values = _personalFormKey.currentState!.value;
        final userDetailsProvider =
            Provider.of<UserDetailsProvider>(context, listen: false);

        final updateData = {
          'firstName': values['firstName'],
          'lastName': values['lastName'],
        };

        final response = await userDetailsProvider.update(userId!, updateData);

        if (response.success && mounted) {
          setState(() {
            displayName =
                '${values['firstName']} ${values['lastName']}'.trim();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Personal information updated successfully')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.errorMessage}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveAddress() async {
    if (_addressFormKey.currentState?.saveAndValidate() ?? false) {
      if (userId == null) return;

      try {
        final values = _addressFormKey.currentState!.value;
        final userAddressProvider =
            Provider.of<UserAddressProvider>(context, listen: false);

        final response = await userAddressProvider.update(userId!, values);

        if (response.success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address updated successfully')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.errorMessage}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating address: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveSettings() async {
    if (userId == null) return;

    try {
      final notificationProvider =
          Provider.of<NotificationSettingsProvider>(context, listen: false);
      
      await notificationProvider.updateNotificationSettings(
        notificationsEnabled: _emailNotifications,
        pushNotificationsEnabled: _pushNotifications,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings updated successfully'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: AppButtonStyles.danger,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && userId != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deletion not implemented yet')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Clear cart for current user
      await cartProvider.clearUser();
      
      // Logout from auth
      await authProvider.logout();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.black,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
        
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.black,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.grey[300],
              tabs: const [
                Tab(text: 'Personal'),
                Tab(text: 'Address'),
                Tab(text: 'Settings'),
              ],
            ),
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalTab(),
                    _buildAddressTab(),
                    _buildSettingsTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab() {
    return FormBuilder(
      key: _personalFormKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: _buildFormField('First Name', 'firstName'),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildFormField('Last Name', 'lastName'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildFormField('Email', 'email', enabled: false),
            const SizedBox(height: 15),
            _buildFormField('Phone', 'phone', enabled: false),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _savePersonalInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTab() {
    return FormBuilder(
      key: _addressFormKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildFormField('Street Address', 'street'),
            const SizedBox(height: 15),
            _buildFormField('City', 'city'),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildFormField('State/Province', 'state'),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildFormField('ZIP/Postal Code', 'zipCode'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildFormField('Country', 'country'),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Notification Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildSwitchTile(
            'Email Notifications',
            'Receive updates via email',
            _emailNotifications,
            (value) async {
              setState(() => _emailNotifications = value);
              await _saveSettings();
            },
          ),
          const SizedBox(height: 10),
          _buildSwitchTile(
            'Push Notifications',
            'Receive alerts on your device',
            _pushNotifications,
            (value) async {
              setState(() => _pushNotifications = value);
              await _saveSettings();
            },
          ),
          const SizedBox(height: 30),
          Text(
            'Danger Zone',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _deleteAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFD32F2F)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String name, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        FormBuilderTextField(
          name: name,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}
