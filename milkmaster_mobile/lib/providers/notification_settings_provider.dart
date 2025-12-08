import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/providers/settings_provider.dart';
import 'package:milkmaster_mobile/services/notification_service.dart';

class NotificationSettingsProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final SettingsProvider _settingsProvider;
  
  bool _notificationsEnabled = false;
  bool _pushNotificationsEnabled = false;
  bool _permissionGranted = false;
  String? _userId;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get permissionGranted => _permissionGranted;

  NotificationSettingsProvider(this._settingsProvider);

  Future<void> initialize(String userId) async {
    _userId = userId;
    
    // Initialize notification service
    await _notificationService.initialize();
    
    // Request permissions
    _permissionGranted = await _notificationService.requestPermissions();
    
    // Load settings from backend
    await loadSettings();
    
    notifyListeners();
  }

  Future<void> loadSettings() async {
    if (_userId == null) return;

    try {
      final settings = await _settingsProvider.getById(_userId!);
      
      if (settings != null) {
        _notificationsEnabled = settings.notificationsEnabled;
        _pushNotificationsEnabled = settings.pushNotificationsEnabled;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool pushNotificationsEnabled,
  }) async {
    if (_userId == null) return;

    try {
      final updateData = {
        'notificationsEnabled': notificationsEnabled,
        'pushNotificationsEnabled': pushNotificationsEnabled,
      };

      final response = await _settingsProvider.update(_userId!, updateData);

      if (response.success) {
        _notificationsEnabled = notificationsEnabled;
        _pushNotificationsEnabled = pushNotificationsEnabled;
        
        // If push notifications are disabled, cancel all pending notifications
        if (!pushNotificationsEnabled) {
          await _notificationService.cancelAllNotifications();
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      rethrow;
    }
  }

  Future<void> showNotificationIfEnabled({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Check if push notifications are enabled in settings and permission is granted
    if (_pushNotificationsEnabled && _permissionGranted) {
      await _notificationService.showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    }
  }

  Future<void> showOrderNotificationIfEnabled({
    required String orderId,
    required String status,
    required String message,
  }) async {
    if (_pushNotificationsEnabled && _permissionGranted) {
      await _notificationService.showOrderNotification(
        orderId: orderId,
        status: status,
        message: message,
      );
    }
  }

  Future<void> showProductNotificationIfEnabled({
    required String productName,
    required String message,
  }) async {
    if (_pushNotificationsEnabled && _permissionGranted) {
      await _notificationService.showProductNotification(
        productName: productName,
        message: message,
      );
    }
  }

  Future<void> requestPermissionsIfNeeded() async {
    if (!_permissionGranted) {
      _permissionGranted = await _notificationService.requestPermissions();
      notifyListeners();
    }
  }

  /// Schedule a daily notification
  /// Example: scheduleDailyNotification(hour: 9, minute: 0, title: 'Daily Reminder', body: 'Check for new products!')
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (_pushNotificationsEnabled && _permissionGranted) {
      await _notificationService.scheduleDailyNotification(
        id: id,
        title: title,
        body: body,
        hour: hour,
        minute: minute,
        payload: payload,
      );
    }
  }

  /// Cancel a specific scheduled notification
  Future<void> cancelScheduledNotification(int id) async {
    await _notificationService.cancelScheduledNotification(id);
  }

  /// Get all pending scheduled notifications
  Future<List<dynamic>> getPendingNotifications() async {
    return await _notificationService.getPendingNotifications();
  }
}
