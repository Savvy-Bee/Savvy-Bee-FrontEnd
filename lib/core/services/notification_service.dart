// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';

// // Background message handler (must be top-level function)
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Handling background message: ${message.messageId}');
//   // Handle background notification here
// }

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();

//   String? _fcmToken;
//   String? get fcmToken => _fcmToken;

//   Future<void> initialize() async {
//     // Request permissions
//     await _requestPermissions();

//     // Configure Firebase Messaging
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // Initialize local notifications
//     await _initializeLocalNotifications();

//     // Get FCM token
//     await _getFCMToken();

//     // Handle foreground messages
//     _configureForegroundHandler();

//     // Handle notification taps
//     _configureNotificationTapHandler();

//     // Listen to token refresh
//     _listenToTokenRefresh();
//   }

//   Future<void> _requestPermissions() async {
//     if (Platform.isIOS) {
//       // iOS permissions
//       final settings = await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );

//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         print('User granted notification permission');
//       } else if (settings.authorizationStatus ==
//           AuthorizationStatus.provisional) {
//         print('User granted provisional notification permission');
//       } else {
//         print('User declined notification permission');
//       }
//     } else {
//       // Android permissions (Android 13+)
//       final status = await Permission.notification.request();
//       if (status.isGranted) {
//         print('Notification permission granted');
//       } else {
//         print('Notification permission denied');
//       }
//     }
//   }

//   Future<void> _initializeLocalNotifications() async {
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );
//   }

//   Future<void> _getFCMToken() async {
//     try {
//       _fcmToken = await _firebaseMessaging.getToken();
//       print('FCM Token: $_fcmToken');
      
//       // TODO: Send this token to your backend
//       // await _sendTokenToBackend(_fcmToken);
//     } catch (e) {
//       print('Error getting FCM token: $e');
//     }
//   }

//   void _configureForegroundHandler() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Received foreground message: ${message.messageId}');

//       // Show local notification when app is in foreground
//       if (message.notification != null) {
//         _showLocalNotification(message);
//       }
//     });
//   }

//   void _configureNotificationTapHandler() {
//     // Handle notification tap when app is in background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Notification tapped: ${message.messageId}');
//       _handleNotificationTap(message);
//     });

//     // Check if app was opened from terminated state
//     _checkInitialMessage();
//   }

//   Future<void> _checkInitialMessage() async {
//     final message = await _firebaseMessaging.getInitialMessage();
//     if (message != null) {
//       print('App opened from terminated state: ${message.messageId}');
//       _handleNotificationTap(message);
//     }
//   }

//   void _listenToTokenRefresh() {
//     _firebaseMessaging.onTokenRefresh.listen((newToken) {
//       print('FCM Token refreshed: $newToken');
//       _fcmToken = newToken;
      
//       // TODO: Send updated token to backend
//       // await _sendTokenToBackend(newToken);
//     });
//   }

//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     final notification = message.notification;
//     final android = message.notification?.android;

//     if (notification != null) {
//       await _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'high_importance_channel',
//             'High Importance Notifications',
//             channelDescription: 'This channel is used for important notifications',
//             importance: Importance.high,
//             priority: Priority.high,
//             icon: '@mipmap/ic_launcher',
//           ),
//           iOS: const DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//         payload: message.data.toString(),
//       );
//     }
//   }

//   void _onNotificationTapped(NotificationResponse response) {
//     print('Notification tapped: ${response.payload}');
//     // Handle notification tap from local notification
//     // Navigate to specific screen based on payload
//   }

//   void _handleNotificationTap(RemoteMessage message) {
//     print('Handling notification tap: ${message.data}');
    
//     // Example: Navigate based on notification data
//     // final data = message.data;
//     // if (data['type'] == 'budget') {
//     //   // Navigate to budget screen
//     // } else if (data['type'] == 'goal') {
//     //   // Navigate to goals screen
//     // }
//   }

//   // Subscribe to topics
//   Future<void> subscribeToTopic(String topic) async {
//     try {
//       await _firebaseMessaging.subscribeToTopic(topic);
//       print('Subscribed to topic: $topic');
//     } catch (e) {
//       print('Error subscribing to topic: $e');
//     }
//   }

//   // Unsubscribe from topics
//   Future<void> unsubscribeFromTopic(String topic) async {
//     try {
//       await _firebaseMessaging.unsubscribeFromTopic(topic);
//       print('Unsubscribed from topic: $topic');
//     } catch (e) {
//       print('Error unsubscribing from topic: $e');
//     }
//   }

//   // Delete FCM token (useful for logout)
//   Future<void> deleteToken() async {
//     try {
//       await _firebaseMessaging.deleteToken();
//       _fcmToken = null;
//       print('FCM token deleted');
//     } catch (e) {
//       print('Error deleting FCM token: $e');
//     }
//   }
// }