import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await _messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification: ${message.notification?.title}");
    });
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  static Future<void> refreshToken(Function(String token) onToken) async {
    FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
  }
}