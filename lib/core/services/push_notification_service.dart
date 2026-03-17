import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:savvy_bee_mobile/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef NotificationHandler = FutureOr<void> Function(RemoteMessage message);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotificationService.instance._handleBackgroundMessage(message);
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const String _fcmTokenKey = 'fcm_token';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final StreamController<RemoteMessage> _foregroundStreamController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _backgroundStreamController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _tapStreamController =
      StreamController<RemoteMessage>.broadcast();

  NotificationHandler? _foregroundHandler;
  NotificationHandler? _backgroundHandler;
  NotificationHandler? _tapHandler;

  bool _isInitialized = false;

  Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundStreamController.stream;
  Stream<RemoteMessage> get onBackgroundMessage =>
      _backgroundStreamController.stream;
  Stream<RemoteMessage> get onNotificationTap => _tapStreamController.stream;

  bool get isInitialized => _isInitialized;

  Future<void> initialize({
    NotificationHandler? onForegroundMessage,
    NotificationHandler? onBackgroundMessage,
    NotificationHandler? onNotificationTap,
  }) async {
    if (_isInitialized) return;

    _foregroundHandler = onForegroundMessage;
    _backgroundHandler = onBackgroundMessage;
    _tapHandler = onNotificationTap;

    await _messaging.setAutoInitEnabled(true);
    await _requestPermissions();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _handleInitialMessage();

    // Fetch and persist the FCM token on first init.
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);

    // Keep the stored token up-to-date whenever Firebase rotates it.
    _messaging.onTokenRefresh.listen(_saveToken);

    _isInitialized = true;
  }

  /// Returns the FCM token from local storage if available, otherwise fetches
  /// it from Firebase, persists it, and returns it.
  Future<String?> getStoredOrFetchToken() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_fcmTokenKey);
    if (stored != null && stored.isNotEmpty) return stored;

    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);
    return token;
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, token);
      debugPrint('[PushNotificationService] FCM token saved');
    } catch (e) {
      debugPrint('[PushNotificationService] Failed to save FCM token: $e');
    }
  }

  void listenToTokenRefresh(ValueChanged<String> onToken) {
    _messaging.onTokenRefresh.listen(onToken);
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    debugPrint('Push notification permission status: '
        '${settings.authorizationStatus}');
  }

  Future<void> _handleInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _foregroundStreamController.add(message);
    _safeInvoke(_foregroundHandler, message);
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    _backgroundStreamController.add(message);
    await _safeInvokeAsync(_backgroundHandler, message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    _tapStreamController.add(message);
    _safeInvoke(_tapHandler, message);
  }

  void _safeInvoke(NotificationHandler? handler, RemoteMessage message) {
    if (handler == null) {
      if (kDebugMode) {
        debugPrint(_formatLog('No handler registered for this event.', message));
      }
      return;
    }

    try {
      handler(message);
    } catch (error, stackTrace) {
      debugPrint(
        _formatLog(
          'Error running notification handler: $error\n$stackTrace',
          message,
        ),
      );
    }
  }

  Future<void> _safeInvokeAsync(
    NotificationHandler? handler,
    RemoteMessage message,
  ) async {
    if (handler == null) {
      if (kDebugMode) {
        debugPrint(_formatLog('No handler registered for this event.', message));
      }
      return;
    }

    try {
      await Future.sync(() => handler(message));
    } catch (error, stackTrace) {
      debugPrint(
        _formatLog(
          'Error running notification handler: $error\n$stackTrace',
          message,
        ),
      );
    }
  }

  String _formatLog(String message, RemoteMessage remoteMessage) {
    return '[PushNotificationService] $message | '
        'notificationId=${remoteMessage.messageId ?? "unknown"}';
  }
}
