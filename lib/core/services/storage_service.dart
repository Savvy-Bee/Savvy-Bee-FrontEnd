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
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String biometricEmailKey = 'biometric_email';
  static const String _biometricPasswordKey = 'biometric_password';
  static const String _biometricLastFullLoginKey = 'biometric_last_full_login';
  static const String _biometricFailureCountKey = 'biometric_failure_count';
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

  // ------------------- BIOMETRIC PREFERENCES -------------------

  Future<bool> getBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(biometricEnabledKey) ?? false;
    } catch (e) {
      log('✗ Error reading biometric enabled: $e');
      return false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(biometricEnabledKey, enabled);
      log('✓ Biometric enabled set to: $enabled');
    } catch (e) {
      log('✗ Error saving biometric enabled: $e');
      rethrow;
    }
  }

  /// Store email in secure storage so the lock screen can show which account is locked
  Future<void> saveBiometricEmail(String email) async {
    try {
      await _secureStorage.write(key: biometricEmailKey, value: email);
      log('✓ Biometric email saved');
    } catch (e) {
      log('✗ Error saving biometric email: $e');
      rethrow;
    }
  }

  Future<String?> getBiometricEmail() async {
    try {
      return await _secureStorage.read(key: biometricEmailKey);
    } catch (e) {
      log('✗ Error reading biometric email: $e');
      return null;
    }
  }

  /// Save email + password to hardware-backed secure storage.
  /// Called on every successful password login so silent re-auth is always
  /// possible regardless of when biometrics are enabled.
  Future<void> saveBiometricCredentials(String email, String password) async {
    try {
      await _secureStorage.write(key: biometricEmailKey, value: email);
      await _secureStorage.write(key: _biometricPasswordKey, value: password);
      log('✓ Biometric credentials saved');
    } catch (e) {
      log('✗ Error saving biometric credentials: $e');
      rethrow;
    }
  }

  /// Returns `{email, password}` if stored, otherwise null.
  Future<({String email, String password})?> getBiometricCredentials() async {
    try {
      final email = await _secureStorage.read(key: biometricEmailKey);
      final password = await _secureStorage.read(key: _biometricPasswordKey);
      if (email == null || password == null) return null;
      return (email: email, password: password);
    } catch (e) {
      log('✗ Error reading biometric credentials: $e');
      return null;
    }
  }

  Future<void> deleteBiometricCredentials() async {
    try {
      await _secureStorage.delete(key: biometricEmailKey);
      await _secureStorage.delete(key: _biometricPasswordKey);
      log('✓ Biometric credentials deleted');
    } catch (e) {
      log('✗ Error deleting biometric credentials: $e');
    }
  }

  /// Records the timestamp of the last time the user authenticated with
  /// their email + password (not biometrics). Used to enforce the 30-day limit.
  Future<void> saveBiometricLastFullLoginDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _biometricLastFullLoginKey,
        DateTime.now().toIso8601String(),
      );
      log('✓ Biometric last full login date saved');
    } catch (e) {
      log('✗ Error saving biometric last full login date: $e');
    }
  }

  Future<DateTime?> getBiometricLastFullLoginDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_biometricLastFullLoginKey);
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    } catch (e) {
      log('✗ Error reading biometric last full login date: $e');
      return null;
    }
  }

  Future<int> getBiometricFailureCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_biometricFailureCountKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> incrementBiometricFailureCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_biometricFailureCountKey) ?? 0;
      await prefs.setInt(_biometricFailureCountKey, current + 1);
    } catch (e) {
      log('✗ Error incrementing biometric failure count: $e');
    }
  }

  Future<void> clearBiometricFailureCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_biometricFailureCountKey);
    } catch (e) {
      log('✗ Error clearing biometric failure count: $e');
    }
  }

  Future<void> deleteBiometricData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(biometricEnabledKey);
      await prefs.remove(_biometricLastFullLoginKey);
      await prefs.remove(_biometricFailureCountKey);
      await _secureStorage.delete(key: biometricEmailKey);
      await _secureStorage.delete(key: _biometricPasswordKey);
      log('✓ Biometric data cleared');
    } catch (e) {
      log('✗ Error clearing biometric data: $e');
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

