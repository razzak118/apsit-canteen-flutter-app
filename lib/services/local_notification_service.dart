import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  final Map<int, String> _lastNotifiedStatusByOrderId = {};

  static const AndroidNotificationChannel _ordersChannel =
      AndroidNotificationChannel(
    'order_updates_channel',
    'Order Updates',
    description: 'Notifications for live order status changes',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

    await _plugin.initialize(settings);

    final androidPlugin = _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_ordersChannel);

    _initialized = true;
  }

  Future<void> requestPermissionIfNeeded() async {
    final androidPlugin = _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<bool> ensurePermission() async {
    final androidPlugin = _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final enabledBeforeRequest = await androidPlugin?.areNotificationsEnabled();
    if (enabledBeforeRequest == true) {
      return true;
    }

    await androidPlugin?.requestNotificationsPermission();
    final enabledAfterRequest = await androidPlugin?.areNotificationsEnabled();
    return enabledAfterRequest ?? false;
  }

  Future<bool> showOrderStatusUpdate({
    required int? orderId,
    required String status,
  }) async {
    await initialize();
    final permitted = await ensurePermission();
    if (!permitted) return false;

    final normalizedStatus = status.trim().toUpperCase();
    final id = orderId;

    if (id != null) {
      final last = _lastNotifiedStatusByOrderId[id];
      if (last == normalizedStatus) return false;
      _lastNotifiedStatusByOrderId[id] = normalizedStatus;
    }

    final title = _buildTitle(id, normalizedStatus);
    final body = _buildBody(id, normalizedStatus);
    final ticker = _buildTicker(normalizedStatus);

    final notificationId = DateTime.now().microsecondsSinceEpoch.remainder(2147483647);

    await _plugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _ordersChannel.id,
          _ordersChannel.name,
          channelDescription: _ordersChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          ticker: ticker,
          category: AndroidNotificationCategory.status,
          playSound: true,
          enableVibration: true,
          autoCancel: true,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'APSIT Canteen',
          ),
        ),
      ),
    );

    return true;
  }

  String _buildTitle(int? orderId, String normalizedStatus) {
    final prefix = orderId == null ? 'Your order' : 'Order #$orderId';

    switch (normalizedStatus) {
      case 'PENDING':
        return '📝 $prefix placed successfully';
      case 'IN_PROGRESS':
        return '👨‍🍳 $prefix is being prepared';
      case 'READY':
        return '✅ $prefix is ready for pickup';
      case 'DELIVERED':
        return '🎉 $prefix delivered';
      case 'CANCELLED':
        return '⚠️ $prefix was cancelled';
      default:
        return '🔔 $prefix status updated';
    }
  }

  String _buildBody(int? orderId, String normalizedStatus) {
    final orderRef = orderId == null ? 'your order' : 'order #$orderId';

    switch (normalizedStatus) {
      case 'PENDING':
        return 'We received $orderRef and it is now in queue.';
      case 'IN_PROGRESS':
        return 'Good news! Kitchen has started preparing $orderRef.';
      case 'READY':
        return 'Please head to the counter and show your QR to collect $orderRef.';
      case 'DELIVERED':
        return 'Enjoy your meal! $orderRef has been marked as delivered.';
      case 'CANCELLED':
        return 'We are sorry, $orderRef was cancelled. Please contact support if needed.';
      default:
        return '${normalizedStatus.replaceAll('_', ' ')} update received for $orderRef.';
    }
  }

  String _buildTicker(String normalizedStatus) {
    switch (normalizedStatus) {
      case 'READY':
        return 'Order ready';
      case 'IN_PROGRESS':
        return 'Order in progress';
      case 'PENDING':
        return 'Order placed';
      case 'DELIVERED':
        return 'Order delivered';
      case 'CANCELLED':
        return 'Order cancelled';
      default:
        return 'Order update';
    }
  }
}
