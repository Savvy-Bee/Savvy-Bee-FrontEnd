import 'package:shared_preferences/shared_preferences.dart';

class NahlConsentService {
  static const _key = 'nahl_chat_consent_granted';

  /// Returns true if the user has previously granted consent.
  static Future<bool> hasConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Persists the user's consent decision.
  static Future<void> saveConsent(bool agreed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, agreed);
  }

  /// Clears stored consent (useful for testing / account reset).
  static Future<void> clearConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
