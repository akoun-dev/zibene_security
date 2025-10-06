import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> init() async {
    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    // Initialize settings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Request permissions
    await _requestPermissions();
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  // Show local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'zibene_security_channel',
      'Zibene Security Notifications',
      channelDescription: 'Security service notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Schedule notification (requires timezone dependency)
  // Future<void> scheduleNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required DateTime scheduledTime,
  //   String? payload,
  // }) async {
  //   // TODO: Implement with timezone dependency
  // }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Show booking reminder notification
  Future<void> showBookingReminder({
    required String bookingId,
    required String agentName,
    required DateTime bookingTime,
  }) async {
    await showNotification(
      id: bookingId.hashCode,
      title: 'Booking Reminder',
      body: 'Your booking with $agentName is scheduled for ${_formatDateTime(bookingTime)}',
      payload: 'booking_$bookingId',
    );
  }

  // Show new booking notification
  Future<void> showNewBookingNotification({
    required String bookingId,
    required String clientName,
  }) async {
    await showNotification(
      id: 'new_booking_$bookingId'.hashCode,
      title: 'New Booking Request',
      body: 'You have a new booking request from $clientName',
      payload: 'new_booking_$bookingId',
    );
  }

  // Show booking status update notification
  Future<void> showBookingStatusNotification({
    required String bookingId,
    required String status,
  }) async {
    String title, body;

    switch (status) {
      case 'confirmed':
        title = 'Booking Confirmed';
        body = 'Your booking has been confirmed';
        break;
      case 'cancelled':
        title = 'Booking Cancelled';
        body = 'Your booking has been cancelled';
        break;
      case 'completed':
        title = 'Booking Completed';
        body = 'Your booking has been completed. Please leave a review.';
        break;
      default:
        title = 'Booking Update';
        body = 'Your booking status has been updated to $status';
    }

    await showNotification(
      id: 'status_$bookingId'.hashCode,
      title: title,
      body: body,
      payload: 'booking_status_$bookingId',
    );
  }

  // Show payment notification
  Future<void> showPaymentNotification({
    required String bookingId,
    required double amount,
    required bool success,
  }) async {
    await showNotification(
      id: 'payment_$bookingId'.hashCode,
      title: success ? 'Payment Successful' : 'Payment Failed',
      body: success
          ? 'Payment of \$${amount.toStringAsFixed(2)} was successful'
          : 'Payment failed. Please try again.',
      payload: 'payment_$bookingId',
    );
  }

  // Show system notification
  Future<void> showSystemNotification({
    required String title,
    required String message,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: message,
      payload: 'system_notification',
    );
  }

  // Handle notification tap
  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // Handle notification tap based on payload
      _handleNotificationTap(payload);
    }
  }

  // Handle iOS notification
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    // Handle iOS notification
  }

  // Handle notification tap based on payload
  void _handleNotificationTap(String payload) {
    // This will be handled by the app's routing system
    // You can navigate to specific screens based on payload
    debugPrint('Notification tapped: $payload');
  }

  // Format date time for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Create and store notification in database
  Future<void> createAndSendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? data,
  }) async {
    // Store in database
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

    // Show local notification
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: message,
      payload: data,
    );
  }

  // Send booking confirmation
  Future<void> sendBookingConfirmation({
    required String userId,
    required String bookingId,
    required String agentName,
    required DateTime bookingTime,
  }) async {
    await createAndSendNotification(
      userId: userId,
      title: 'Booking Confirmed',
      message: 'Your booking with $agentName has been confirmed for ${_formatDateTime(bookingTime)}',
      type: 'booking_confirmed',
      data: 'booking_$bookingId',
    );
  }

  // Send booking reminder
  Future<void> sendBookingReminder({
    required String userId,
    required String bookingId,
    required String agentName,
    required DateTime bookingTime,
  }) async {
    await createAndSendNotification(
      userId: userId,
      title: 'Booking Reminder',
      message: 'Reminder: Your booking with $agentName is in 1 hour',
      type: 'booking_reminder',
      data: 'booking_$bookingId',
    );
  }

  // Send agent approval notification
  Future<void> sendAgentApprovalNotification(String userId) async {
    await createAndSendNotification(
      userId: userId,
      title: 'Account Approved',
      message: 'Your agent account has been approved. You can now receive bookings.',
      type: 'account_approved',
      data: 'account_approved',
    );
  }

  // Send new message notification
  Future<void> sendNewMessageNotification({
    required String userId,
    required String senderName,
    required String message,
  }) async {
    await createAndSendNotification(
      userId: userId,
      title: 'New Message from $senderName',
      message: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      type: 'new_message',
      data: 'new_message',
    );
  }
}