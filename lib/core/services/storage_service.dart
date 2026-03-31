import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;

  // Keys
  static const String authTokenKey = 'auth_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String fcmTokenKey = 'fcm_token';
  static const Set<String> _preservedDeviceScopedKeys = {
    'home_walkthrough_completed',
    'tools_walkthrough_completed',
    'dashboard_walkthrough_completed',
    'budget_walkthrough_completed',
    'debt_walkthrough_completed',
  };

  StorageService() : _secureStorage = const FlutterSecureStorage();

  // ------------------- AUTH TOKEN / PERSISTENT LOGIN -------------------

  /// Save auth token with expiry timestamp (24 hours from now)
  Future<void> saveAuthToken(String token) async {
    try {
      // Save to secure storage
      await _secureStorage.write(key: authTokenKey, value: token);

      // Save expiry timestamp
      final expiryTime = DateTime.now().add(const Duration(hours: 24));
      await _secureStorage.write(
        key: tokenExpiryKey,
        value: expiryTime.toIso8601String(),
      );

      // Also store a copy in SharedPreferences for quick access if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(authTokenKey, token);

      log('✓ Auth token saved with 24-hour expiry');
    } catch (e) {
      log('✗ Error saving auth token: $e');
      rethrow;
    }
  }



  /// Get auth token (null if expired)
  Future<String?> getAuthToken() async {
    try {
      final token = await _secureStorage.read(key: authTokenKey);
      if (token == null) return null;

      if (await isTokenExpired()) {
        await deleteAuthToken();
        return null;
      }
      return token;
    } catch (e) {
      log('✗ Error reading auth token: $e');
      return null;
    }
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    try {
      final expiryString = await _secureStorage.read(key: tokenExpiryKey);
      if (expiryString == null) return true;
      final expiryTime = DateTime.parse(expiryString);
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      log('✗ Error checking token expiry: $e');
      return true;
    }
  }


  /// Get remaining token validity time
  Future<Duration?> getTokenRemainingTime() async {
    try {
      final expiryString = await _secureStorage.read(key: tokenExpiryKey);
      
      if (expiryString == null) return null;

      final expiryTime = DateTime.parse(expiryString);
      final now = DateTime.now();
      
      if (now.isAfter(expiryTime)) return null;
      
      return expiryTime.difference(now);
    } catch (e) {
      log('✗ Error getting token remaining time: $e');
      return null;
    }
  }

  /// Delete auth token and expiry
  Future<void> deleteAuthToken() async {
    try {
      await _secureStorage.delete(key: authTokenKey);
      await _secureStorage.delete(key: tokenExpiryKey);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(authTokenKey);

      log('✓ Auth token and expiry deleted');
    } catch (e) {
      log('✗ Error deleting auth token: $e');
      rethrow;
    }
  }

  /// Check if user has valid session
  Future<bool> hasValidSession() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ------------------- FCM TOKEN -------------------

  Future<void> saveFcmToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(fcmTokenKey, token);
      log('✓ FCM token saved');
    } catch (e) {
      log('✗ Error saving FCM token: $e');
    }
  }

  Future<String?> getFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(fcmTokenKey);
    } catch (e) {
      log('✗ Error reading FCM token: $e');
      return null;
    }
  }

  // ------------------- GENERAL SHARED PREFERENCES DATA -------------------

  /// Save data (non-sensitive)
  /// If key is authTokenKey, also handle token expiry
  Future<void> saveData(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);

      // If this is the auth token, also save to secure storage with expiry
      if (key == authTokenKey) {
        await _secureStorage.write(key: authTokenKey, value: value);
        final expiryTime = DateTime.now().add(const Duration(hours: 24));
        await _secureStorage.write(
          key: tokenExpiryKey,
          value: expiryTime.toIso8601String(),
        );
        log('✓ Auth token also saved in secure storage with expiry');
      }

      log('✓ Data saved for key: $key');
    } catch (e) {
      log('✗ Error saving data: $e');
      rethrow;
    }
  }

  /// Get data (non-sensitive)
  /// If key is authTokenKey, check token expiry
  Future<String?> getData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(key);

      // If auth token, verify expiry
      if (key == authTokenKey) {
        if (await isTokenExpired()) {
          await deleteAuthToken();
          return null;
        }
      }

      return value;
    } catch (e) {
      log('✗ Error reading data: $e');
      return null;
    }
  }

  /// Delete data (non-sensitive)
  /// If key is authTokenKey, also delete from secure storage
  Future<void> deleteData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);

      if (key == authTokenKey) {
        await _secureStorage.delete(key: authTokenKey);
        await _secureStorage.delete(key: tokenExpiryKey);
      }

      log('✓ Data deleted for key: $key');
    } catch (e) {
      log('✗ Error deleting data: $e');
      rethrow;
    }
  }

  /// Clear all storage (SharedPreferences + secure storage)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preservedValues = <String, Object>{};

      for (final key in _preservedDeviceScopedKeys) {
        final value = prefs.get(key);
        if (value != null) {
          preservedValues[key] = value;
        }
      }

      await prefs.clear();

      for (final entry in preservedValues.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List<String>) {
          await prefs.setStringList(key, value);
        }
      }

      await _secureStorage.deleteAll();
      log('Storage cleared (device walkthrough state preserved)');
    } catch (e) {
      log('Error clearing all storage: $e');
      rethrow;
    }
  }
}

