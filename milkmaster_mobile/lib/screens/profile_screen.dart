import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:milkmaster_mobile/providers/auth_provider.dart';
import 'package:milkmaster_mobile/providers/cart_provider.dart';
import 'package:milkmaster_mobile/providers/notification_settings_provider.dart';
import 'package:milkmaster_mobile/providers/settings_provider.dart';
import 'package:milkmaster_mobile/providers/user_address_provider.dart';
import 'package:milkmaster_mobile/providers/user_details_provider.dart';
import 'package:milkmaster_mobile/providers/user_provider.dart';
import 'package:milkmaster_mobile/utils/widget_helpers.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:country_state_city_pro/country_state_city_pro.dart';

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
  bool _hasUserDetails = false; // Track if user details exist
  bool _hasUserAddress = false; // Track if user address exists

  // Store user data
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String? _imageUrl;
  bool _isUploadingImage = false;

  // Address data
  String _street = '';
  String _zipCode = '';

  // Controllers for country, state, city pickers
  final TextEditingController _countryCont = TextEditingController();
  final TextEditingController _stateCont = TextEditingController();
  final TextEditingController _cityCont = TextEditingController();

  // Error messages for picker fields
  String? _countryError;
  String? _stateError;
  String? _cityError;

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

      final userDetailsProvider = Provider.of<UserDetailsProvider>(
        context,
        listen: false,
      );
      final userDetails = await userDetailsProvider.getById(userId!);

      final userAddressProvider = Provider.of<UserAddressProvider>(
        context,
        listen: false,
      );
      final userAddress = await userAddressProvider.getById(userId!);

      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );
      final settings = await settingsProvider.getById(userId!);

      if (mounted) {
        setState(() {
          _email = user.email;
          _phone = user.phoneNumber ?? '';

          if (userDetails != null) {
            _hasUserDetails = true;
            _firstName = userDetails.firstName ?? '';
            _lastName = userDetails.lastName ?? '';
            _imageUrl = userDetails.imageUrl;
            displayName =
                '$_firstName $_lastName'.trim().isEmpty
                    ? user.userName
                    : '$_firstName $_lastName';
          } else {
            _hasUserDetails = false;
            _firstName = '';
            _lastName = '';
            _imageUrl = null;
            displayName = user.userName;
          }

          if (settings != null) {
            _emailNotifications = settings.notificationsEnabled;
            _pushNotifications = settings.pushNotificationsEnabled;
          }

          if (userAddress != null) {
            _hasUserAddress = true;
            _street = userAddress.street ?? '';
            _zipCode = userAddress.zipCode ?? '';
            _countryCont.text = userAddress.country ?? '';
            _stateCont.text = userAddress.state ?? '';
            _cityCont.text = userAddress.city ?? '';
          } else {
            _hasUserAddress = false;
          }
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

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Confirm Update'),
              content: const Text(
                'Are you sure you want to update your personal information?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
      );

      if (confirmed != true) return;

      try {
        final values = _personalFormKey.currentState!.value;
        final userDetailsProvider = Provider.of<UserDetailsProvider>(
          context,
          listen: false,
        );
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Update user details (firstName, lastName)
        final data = {
          'firstName': values['firstName'],
          'lastName': values['lastName'],
          if (_imageUrl != null) 'imageUrl': _imageUrl,
        };

        final response =
            _hasUserDetails
                ? await userDetailsProvider.update(userId!, data)
                : await userDetailsProvider.create({
                  'userId': userId!,
                  ...data,
                });

        if (!response.success) {
          throw Exception(response.errorMessage);
        }

        // Update email if changed
        if (values['email'] != _email) {
          final emailSuccess = await userProvider.updateEmail(
            userId!,
            values['email'],
          );
          if (!emailSuccess) {
            throw Exception(
              'Failed to update email. Email may already be in use.',
            );
          }
          _email = values['email'];
        }

        // Update phone if changed
        if (values['phone'] != _phone) {
          final phoneSuccess = await userProvider.updatePhoneNumber(
            userId!,
            values['phone'],
          );
          if (!phoneSuccess) {
            throw Exception('Failed to update phone number.');
          }
          _phone = values['phone'];
        }

        if (mounted) {
          setState(() {
            _hasUserDetails = true;
            displayName = '${values['firstName']} ${values['lastName']}'.trim();
          });

          // Show push notification
          final notificationProvider =
              Provider.of<NotificationSettingsProvider>(context, listen: false);
          await notificationProvider.showNotificationIfEnabled(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: 'Profile Updated',
            body: 'Your personal information has been updated successfully!',
            payload: 'profile_update',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Personal information updated successfully',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _saveAddress() async {
    // Clear previous errors
    setState(() {
      _countryError = null;
      _stateError = null;
      _cityError = null;
    });

    // Validate picker fields
    bool hasErrors = false;

    if (_countryCont.text.isEmpty) {
      setState(() => _countryError = 'Please select a country');
      hasErrors = true;
    }

    if (_stateCont.text.isEmpty) {
      setState(() => _stateError = 'Please select a state/province');
      hasErrors = true;
    }

    if (_cityCont.text.isEmpty) {
      setState(() => _cityError = 'Please select a city');
      hasErrors = true;
    }

    if (hasErrors) return;

    if (_addressFormKey.currentState?.saveAndValidate() ?? false) {
      if (userId == null) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Confirm Update',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              content: const Text(
                'Are you sure you want to update your address information?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
      );

      if (confirmed != true) return;

      try {
        final values = _addressFormKey.currentState!.value;
        final userAddressProvider = Provider.of<UserAddressProvider>(
          context,
          listen: false,
        );

        // Get all address values from the form and controllers
        final addressData = {
          'userId': userId!,
          'street': values['street'],
          'zipCode': values['zipCode'],
          'country': _countryCont.text,
          'state': _stateCont.text,
          'city': _cityCont.text,
        };

        // Update local state
        setState(() {
          _street = values['street'] ?? '';
          _zipCode = values['zipCode'] ?? '';
        });

        // Use POST for first time, PUT for updates
        final response =
            _hasUserAddress
                ? await userAddressProvider.update(userId!, addressData)
                : await userAddressProvider.create(addressData);

        if (response.success && mounted) {
          setState(() {
            _hasUserAddress = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Address saved successfully',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.errorMessage}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating address: $e')));
        }
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (userId == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      final userDetailsProvider = Provider.of<UserDetailsProvider>(
        context,
        listen: false,
      );

      // Upload image and get URL
      final imageUrl = await userDetailsProvider.uploadProfileImage(
        File(image.path),
        userId!,
      );

      if (imageUrl != null && mounted) {
        setState(() {
          _imageUrl = imageUrl;
          _isUploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Profile image updated successfully',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (userId == null) return;

    try {
      final notificationProvider = Provider.of<NotificationSettingsProvider>(
        context,
        listen: false,
      );

      await notificationProvider.updateNotificationSettings(
        notificationsEnabled: _emailNotifications,
        pushNotificationsEnabled: _pushNotifications,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Settings updated successfully',
              style: TextStyle(color: Colors.black),
            ),
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
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Account',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: const Color(0xFFD32F2F),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true && userId != null) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final success = await userProvider.delete(userId!);

        if (success) {
          await cartProvider.clearUser();

          await authProvider.logout();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Account deleted successfully',
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            );

            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        } else {
          throw Exception('Failed to delete account');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
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
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countryCont.dispose();
    _stateCont.dispose();
    _cityCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Padding(
                padding: const EdgeInsets.all(15),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _uploadProfileImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              backgroundImage:
                                  _imageUrl != null
                                      ? NetworkImage(
                                        fixLocalhostUrl(_imageUrl!),
                                      )
                                      : null,
                              child:
                                  _isUploadingImage
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : _imageUrl == null
                                      ? ClipOval(
                                        child: leadingIcon(
                                          'assets/icons/user_icon.png',
                                          width: 100,
                                          height: 100,
                                        ),
                                      )
                                      : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _uploadProfileImage,
                              child: Container(
                                width: 32,
                                height: 32,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 33,
                                ),
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
                          foregroundColor:
                              Theme.of(context).colorScheme.secondary,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
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
              ),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: TabBar(
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
                    borderSide: BorderSide(width: 2.0, color: Colors.black),
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.grey[300],
                  tabs: const [
                    Tab(text: 'Personal'),
                    Tab(text: 'Address'),
                    Tab(text: 'Settings'),
                  ],
                ),
              ),
              Container(
                height: 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalTab(),
                    _buildAddressTab(),
                    _buildSettingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalTab() {
    return FormBuilder(
      key: _personalFormKey,
      initialValue: {
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'phone': _phone,
      },
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          'First Name',
                          'firstName',
                          validators: [
                            FormBuilderValidators.required(
                              errorText: 'First name is required',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildFormField(
                          'Last Name',
                          'lastName',
                          validators: [
                            FormBuilderValidators.required(
                              errorText: 'Last name is required',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildFormField(
                    'Email',
                    'email',
                    enabled: true,
                    validators: [
                      FormBuilderValidators.required(
                        errorText: 'Email is required',
                      ),
                      FormBuilderValidators.email(
                        errorText: 'Enter a valid email',
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildFormField(
                    'Phone',
                    'phone',
                    enabled: true,
                    validators: [
                      FormBuilderValidators.required(
                        errorText: 'Phone number is required',
                      ),
                      FormBuilderValidators.match(
                        RegExp(r'^\+?[0-9]{7,15}$'),
                        errorText: 'Enter a valid phone number',
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            height: 75,
            child: ElevatedButton(
              onPressed: _savePersonalInfo,

              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    return FormBuilder(
      key: _addressFormKey,
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormField(
                    'Street Address',
                    'street',
                    initialValue: _street,
                    validators: [
                      FormBuilderValidators.required(
                        errorText: 'Street address is required',
                      ),
                      FormBuilderValidators.minLength(
                        3,
                        errorText: 'Street address must be at least 3 characters',
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildPickerField('City', _cityCont, errorText: _cityError),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerField(
                          'State/Province',
                          _stateCont,
                          errorText: _stateError,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildFormField(
                          'ZIP/Postal Code',
                          'zipCode',
                          initialValue: _zipCode,
                          validators: [
                            FormBuilderValidators.required(
                              errorText: 'ZIP/Postal code is required',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildPickerField(
                    'Country',
                    _countryCont,
                    errorText: _countryError,
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            height: 75,
            child: ElevatedButton(
              onPressed: _saveAddress,

              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Settings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label,
    String name, {
    bool enabled = true,
    String? initialValue,
    List<String? Function(String?)>? validators,
  }) {
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
          initialValue: initialValue,
          validator:
              validators != null
                  ? FormBuilderValidators.compose(validators)
                  : null,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

  Widget _buildPickerField(
    String label,
    TextEditingController controller, {
    String? errorText,
  }) {
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
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
          ),
          onTap: () => _showPickerDialog(label, controller),
        ),
      ],
    );
  }

  void _showPickerDialog(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select $label'),
            content: SizedBox(
              width: double.maxFinite,
              child: CountryStateCityPicker(
                country: _countryCont,
                state: _stateCont,
                city: _cityCont,
                dialogColor: Colors.grey.shade200,
                textFieldDecoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }
}
