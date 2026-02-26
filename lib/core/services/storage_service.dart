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

  StorageService() : _secureStorage = const FlutterSecureStorage();

  // ------------------- AUTH TOKEN / PERSISTENT LOGIN -------------------

  /// Save auth token with expiry timestamp (24 hours from now)
  Future<void> saveAuthToken(String token) async {
    try {
      // Save to secure storage
      await _secureStorage.write(key: authTokenKey, value: token);

      // Save expiry timestamp
      final expiryTime = DateTime.now().add(const Duration(days: 30));
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
      await prefs.clear();
      await _secureStorage.deleteAll();
      log('✓ All storage cleared');
    } catch (e) {
      log('✗ Error clearing all storage: $e');
      rethrow;
    }
  }
}
