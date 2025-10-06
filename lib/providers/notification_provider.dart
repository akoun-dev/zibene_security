import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Get user notifications
  Future<void> fetchUserNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final notificationsData = await FirebaseService.getData(
        FirebaseService.notificationsCollection,
        where: (query) => query.where('user_id', isEqualTo: userId),
        orderBy: 'created_at',
        descending: true,
      );
      _notifications = notificationsData
          .map((data) => NotificationModel.fromJson(data))
          .toList();
      _updateUnreadCount();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create notification
  Future<bool> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? data,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirebaseService.insertData(
        FirebaseService.notificationsCollection,
        {
          'user_id': userId,
          'title': title,
          'message': message,
          'type': type,
          'data': data,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // Refresh notifications
      await fetchUserNotifications(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirebaseService.updateData(
        FirebaseService.notificationsCollection,
        notificationId,
        {
          'is_read': true,
        },
      );

      // Update local notification
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    _isLoading = true;
    notifyListeners();

    try {
      for (final notification in _notifications) {
        if (!notification.isRead) {
          await markAsRead(notification.id);
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return _notifications.where((notification) => !notification.isRead).toList();
  }

  // Get read notifications
  List<NotificationModel> get readNotifications {
    return _notifications.where((notification) => notification.isRead).toList();
  }

  // Get recent notifications (last 24 hours)
  List<NotificationModel> get recentNotifications {
    return _notifications.where((notification) => notification.isRecent).toList();
  }

  // Get today's notifications
  List<NotificationModel> get todayNotifications {
    return _notifications.where((notification) => notification.isToday).toList();
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }

  // Get booking notifications
  List<NotificationModel> get bookingNotifications {
    return getNotificationsByType(NotificationType.booking);
  }

  // Get payment notifications
  List<NotificationModel> get paymentNotifications {
    return getNotificationsByType(NotificationType.payment);
  }

  // Get system notifications
  List<NotificationModel> get systemNotifications {
    return getNotificationsByType(NotificationType.system);
  }

  // Get message notifications
  List<NotificationModel> get messageNotifications {
    return getNotificationsByType(NotificationType.message);
  }

  // Get review notifications
  List<NotificationModel> get reviewNotifications {
    return getNotificationsByType(NotificationType.review);
  }

  // Get security notifications
  List<NotificationModel> get securityNotifications {
    return getNotificationsByType(NotificationType.security);
  }

  // Add notification locally (for real-time updates)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }

  // Remove notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    notifyListeners();
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear notifications
  void clearNotifications() {
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }
}