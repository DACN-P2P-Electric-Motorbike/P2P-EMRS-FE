import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

import '../../firebase_options.dart';
import '../localization/notification_text_localizer.dart';

// Global logger for background handler
final Logger _backgroundLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

// Top-level handler for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _backgroundLogger.i('📬 Handling background message: ${message.messageId}');

  // Show notification even when app is in background
  await FcmService._showNotification(message);
}

/// FCM Service for push notifications
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static Locale _currentLocale = const Locale('vi');

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  void setLocale(Locale locale) {
    _currentLocale = locale.languageCode == 'en'
        ? const Locale('en')
        : const Locale('vi');
  }

  // Callbacks
  Function(RemoteMessage)? onNotificationTapped;
  Function(RemoteMessage)? onForegroundMessage;
  Future<void> Function(String token)? onTokenRefresh;

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      _logger.i('Initializing FCM service');

      // Request permissions (iOS)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('✅ FCM: User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        _logger.i('📬 FCM: User granted provisional permission');
      } else {
        _logger.w('⚠️ FCM: User declined or has not granted permission');
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      _fcmToken = await _fcm.getToken();
      if (_fcmToken != null) {
        _logger.i('✅ FCM Token obtained: ${_fcmToken!.substring(0, 20)}...');
      } else {
        _logger.w('⚠️ FCM Token is null');
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        _logger.i('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
        await onTokenRefresh?.call(newToken);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      _logger.d('Background message handler registered');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('📬 Foreground message received: ${message.messageId}');
        _logger.d('Title: ${message.notification?.title}');
        _logger.d('Body: ${message.notification?.body}');

        // Show local notification
        _showNotification(message);

        // Call custom handler
        onForegroundMessage?.call(message);
      });

      // Handle notification taps (app opened from notification)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i(
          '📱 Notification tapped (app in background): ${message.messageId}',
        );
        onNotificationTapped?.call(message);
      });

      // Check if app was opened from a terminated state via notification
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _logger.i('📱 App opened from terminated state via notification');
        onNotificationTapped?.call(initialMessage);
      }

      _logger.i('✅ FCM service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error initializing FCM service',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      _logger.d('Initializing local notifications');

      // Android settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          _logger.i('📱 Local notification tapped: ${details.payload}');
          // Handle tap on local notification
        },
      );

      // Create Android notification channel
      if (Platform.isAndroid) {
        final isVietnamese = _currentLocale.languageCode != 'en';
        final AndroidNotificationChannel channel = AndroidNotificationChannel(
          'booking_notifications',
          isVietnamese ? 'Thông báo đặt xe' : 'Booking Notifications',
          description: isVietnamese
              ? 'Thông báo về đặt xe, chuyến đi và thanh toán'
              : 'Notifications for booking, trip, and payment updates',
          importance: Importance.high,
          playSound: true,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);

        final notificationsEnabled = await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        _logger.d(
          'Android notification permission: ${notificationsEnabled ?? true}',
        );

        _logger.d('✅ Android notification channel created');
      }

      _logger.i('✅ Local notifications initialized');
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error initializing local notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;

      if (notification == null) {
        _backgroundLogger.d('Notification is null, skipping display');
        return;
      }

      final localized = NotificationTextLocalizer.localize(
        type: data['type'] ?? '',
        title: notification.title ?? '',
        message: notification.body ?? '',
        locale: _currentLocale,
      );

      // Android notification details
      final isVietnamese = _currentLocale.languageCode != 'en';
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'booking_notifications',
            isVietnamese ? 'Thông báo đặt xe' : 'Booking Notifications',
            channelDescription: isVietnamese
                ? 'Thông báo về đặt xe, chuyến đi và thanh toán'
                : 'Notifications for booking, trip, and payment updates',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      await _localNotifications.show(
        message.hashCode,
        localized.title,
        localized.message,
        details,
        payload: data['bookingId'],
      );

      _backgroundLogger.d('✅ Notification displayed: ${localized.title}');
    } catch (e, stackTrace) {
      _backgroundLogger.e(
        '❌ Error showing notification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _fcm.deleteToken();
      _fcmToken = null;
      _logger.i('✅ FCM token deleted');
    } catch (e, stackTrace) {
      _logger.e('❌ Error deleting FCM token', error: e, stackTrace: stackTrace);
    }
  }

  void dispose() {
    _logger.d('Disposing FCM service');
    deleteToken();
  }
}
