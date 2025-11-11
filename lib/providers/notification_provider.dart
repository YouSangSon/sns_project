import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/database_service.dart';

class NotificationProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load notifications
  Future<void> loadNotifications(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _notifications = await _databaseService.getUserNotifications(userId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Get notifications stream
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _databaseService.getNotificationsStream(userId);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _databaseService.markNotificationAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _databaseService.markAllNotificationsAsRead(userId);

      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
