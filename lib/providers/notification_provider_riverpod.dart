import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/database_service.dart';

// Notifications stream provider
final notificationsStreamProvider = StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  final databaseService = DatabaseService();
  return databaseService.getNotificationsStream(userId);
});

// Unread count provider
final unreadNotificationsCountProvider = Provider.family<int, String>((ref, userId) {
  final notificationsAsync = ref.watch(notificationsStreamProvider(userId));

  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Notification notifier for mutations
class NotificationNotifier extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _databaseService = DatabaseService();

  NotificationNotifier() : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    try {
      await _databaseService.markNotificationAsRead(notificationId);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _databaseService.markAllNotificationsAsRead(userId);
    } catch (e) {
      // Handle error silently
    }
  }
}

final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<void>>((ref) {
  return NotificationNotifier();
});
