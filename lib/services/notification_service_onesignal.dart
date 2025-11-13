import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

/// OneSignal-based Push Notification Service (Firebase-free)
///
/// This service handles push notifications using OneSignal instead of Firebase.
/// OneSignal supports both iOS and Android without requiring Firebase.
class NotificationServiceOneSignal {
  static final NotificationServiceOneSignal _instance =
      NotificationServiceOneSignal._internal();
  factory NotificationServiceOneSignal() => _instance;
  NotificationServiceOneSignal._internal();

  final ApiService _api = ApiService();

  // OneSignal App ID - Get this from OneSignal dashboard
  static const String _oneSignalAppId = "YOUR_ONESIGNAL_APP_ID";

  bool _initialized = false;

  /// Initialize OneSignal
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialize with App ID
    OneSignal.initialize(_oneSignalAppId);

    // Request notification permission (iOS)
    await OneSignal.Notifications.requestPermission(true);

    // Set up notification opened handler
    OneSignal.Notifications.addClickListener(_onNotificationOpened);

    // Set up notification received handler (foreground)
    OneSignal.Notifications.addForegroundWillDisplayListener(
      _onNotificationReceived,
    );

    _initialized = true;
  }

  /// Get OneSignal Player ID (device token)
  Future<String?> getPlayerId() async {
    final deviceState = await OneSignal.User.getOnesignalId();
    return deviceState;
  }

  /// Register device token with your backend
  Future<void> registerDeviceToken(String userId) async {
    try {
      final playerId = await getPlayerId();

      if (playerId == null) {
        print('Failed to get OneSignal Player ID');
        return;
      }

      // Send player ID to your backend
      await _api.post(
        '/users/$userId/device-token',
        data: {
          'deviceToken': playerId,
          'platform': 'onesignal',
        },
      );

      print('Device token registered: $playerId');
    } catch (e) {
      print('Error registering device token: $e');
    }
  }

  /// Set user ID (for targeted notifications)
  Future<void> setUserId(String userId) async {
    try {
      // Set external user ID
      OneSignal.login(userId);

      print('OneSignal user ID set: $userId');
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  /// Remove user ID (on logout)
  Future<void> removeUserId() async {
    try {
      OneSignal.logout();

      print('OneSignal user ID removed');
    } catch (e) {
      print('Error removing user ID: $e');
    }
  }

  /// Send a notification via backend
  /// Your backend will use OneSignal REST API to send notifications
  Future<void> sendNotification({
    required String recipientUserId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _api.post(
        '/notifications/send',
        data: {
          'recipientUserId': recipientUserId,
          'title': title,
          'message': message,
          'data': data,
        },
      );

      print('Notification sent to user: $recipientUserId');
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  /// Send notification to multiple users
  Future<void> sendNotificationToUsers({
    required List<String> recipientUserIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _api.post(
        '/notifications/send-bulk',
        data: {
          'recipientUserIds': recipientUserIds,
          'title': title,
          'message': message,
          'data': data,
        },
      );

      print('Notification sent to ${recipientUserIds.length} users');
    } catch (e) {
      print('Error sending bulk notification: $e');
      rethrow;
    }
  }

  /// Set notification tags (for segmentation)
  Future<void> setTags(Map<String, String> tags) async {
    try {
      OneSignal.User.addTags(tags);

      print('Tags set: $tags');
    } catch (e) {
      print('Error setting tags: $e');
    }
  }

  /// Remove notification tags
  Future<void> removeTags(List<String> keys) async {
    try {
      OneSignal.User.removeTags(keys);

      print('Tags removed: $keys');
    } catch (e) {
      print('Error removing tags: $e');
    }
  }

  /// Enable/disable notifications
  Future<void> setNotificationEnabled(bool enabled) async {
    try {
      OneSignal.Notifications.requestPermission(enabled);

      print('Notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('Error setting notification state: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final permission = await OneSignal.Notifications.permission;
      return permission;
    } catch (e) {
      print('Error checking notification state: $e');
      return false;
    }
  }

  /// Handle notification opened (user tapped notification)
  void _onNotificationOpened(OSNotificationClickEvent event) {
    print('Notification opened: ${event.notification.jsonRepresentation()}');

    final notification = event.notification;
    final data = notification.additionalData;

    if (data != null) {
      _handleNotificationNavigation(data);
    }
  }

  /// Handle notification received in foreground
  void _onNotificationReceived(OSNotificationWillDisplayEvent event) {
    print('Notification received (foreground): ${event.notification.jsonRepresentation()}');

    // You can choose to display or not display the notification
    // event.preventDefault(); // To prevent display

    // Display the notification
    event.notification.display();
  }

  /// Navigate based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'like':
        final postId = data['postId'] as String?;
        if (postId != null) {
          // Navigate to post detail
          print('Navigate to post: $postId');
          // navigationService.navigateTo('/post/$postId');
        }
        break;

      case 'comment':
        final postId = data['postId'] as String?;
        if (postId != null) {
          // Navigate to post detail with comments
          print('Navigate to post comments: $postId');
          // navigationService.navigateTo('/post/$postId?openComments=true');
        }
        break;

      case 'follow':
        final userId = data['fromUserId'] as String?;
        if (userId != null) {
          // Navigate to user profile
          print('Navigate to user profile: $userId');
          // navigationService.navigateTo('/profile/$userId');
        }
        break;

      case 'price_alert':
        final symbol = data['symbol'] as String?;
        if (symbol != null) {
          // Navigate to asset detail
          print('Navigate to asset: $symbol');
          // navigationService.navigateTo('/asset/$symbol');
        }
        break;

      case 'message':
        final conversationId = data['conversationId'] as String?;
        if (conversationId != null) {
          // Navigate to conversation
          print('Navigate to conversation: $conversationId');
          // navigationService.navigateTo('/messages/$conversationId');
        }
        break;

      case 'portfolio_follower':
        final portfolioId = data['portfolioId'] as String?;
        if (portfolioId != null) {
          // Navigate to portfolio detail
          print('Navigate to portfolio: $portfolioId');
          // navigationService.navigateTo('/portfolio/$portfolioId');
        }
        break;

      default:
        // Navigate to notifications screen
        print('Navigate to notifications');
        // navigationService.navigateTo('/notifications');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      OneSignal.Notifications.clearAll();

      print('All notifications cleared');
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  /// Get notification permission status
  Future<OSNotificationPermission> getPermissionStatus() async {
    final permission = await OneSignal.Notifications.permissionNative();
    return permission;
  }

  /// Prompt for push notification permission
  Future<bool> promptForPermission() async {
    try {
      final accepted = await OneSignal.Notifications.requestPermission(true);
      return accepted;
    } catch (e) {
      print('Error prompting for permission: $e');
      return false;
    }
  }
}

/// Example usage in main.dart:
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize OneSignal
///   final notificationService = NotificationServiceOneSignal();
///   await notificationService.initialize();
///
///   runApp(MyApp());
/// }
///
/// // After user login:
/// await notificationService.setUserId(user.userId);
/// await notificationService.registerDeviceToken(user.userId);
///
/// // Set user tags for segmentation:
/// await notificationService.setTags({
///   'language': 'ko',
///   'interests': 'stocks,crypto',
///   'subscription': 'premium',
/// });
///
/// // On logout:
/// await notificationService.removeUserId();
