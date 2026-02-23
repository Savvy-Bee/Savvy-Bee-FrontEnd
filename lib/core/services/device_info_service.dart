import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to get unique device identifier
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get a unique device identifier
  /// Returns a string that uniquely identifies this device
  static Future<String> getDeviceId() async {
    try {
      if (kIsWeb) {
        // For web, use browser fingerprint
        final webInfo = await _deviceInfo.webBrowserInfo;
        return webInfo.userAgent ?? 'web_unknown';
      } else if (Platform.isAndroid) {
        // For Android, use androidId
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id; // This is the Android ID
      } else if (Platform.isIOS) {
        // For iOS, use identifierForVendor
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'ios_unknown';
      } else {
        return 'unknown_platform';
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return 'error_getting_device_id';
    }
  }

  /// Get detailed device information (optional, for debugging)
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'device_id': androidInfo.id,
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'device_id': iosInfo.identifierForVendor ?? 'unknown',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
        };
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }
    return {'platform': 'unknown'};
  }
}
