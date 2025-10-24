import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  
  // Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  StorageService() : _secureStorage = const FlutterSecureStorage();

  // Secure storage methods for sensitive data
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: authTokenKey);
  }

  Future<void> deleteAuthToken() async {
    await _secureStorage.delete(key: authTokenKey);
  }

  // Shared preferences methods for non-sensitive data
  Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clearAll() async {
    // Clear secure storage
    await _secureStorage.deleteAll();
    
    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}