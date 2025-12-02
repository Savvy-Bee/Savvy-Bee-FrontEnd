import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgressRepository {
  static const String _progressKey = 'quiz_progress';

  Future<Map<String, dynamic>?> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_progressKey);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> saveProgress(Map<String, dynamic> progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress));
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }
}
