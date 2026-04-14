import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPostOnboardingDoneKey = 'post_onboarding_done';

/// Tracks whether the user has completed the financial archetype questionnaire.
/// Persisted in SharedPreferences so it survives app restarts.
/// Completing = submitting to the API. Skipping does NOT mark it done.
class PostOnboardingNotifier extends StateNotifier<bool> {
  PostOnboardingNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kPostOnboardingDoneKey) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPostOnboardingDoneKey, true);
    state = true;
  }

  /// Call on logout to reset so the next user is prompted.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPostOnboardingDoneKey);
    state = false;
  }
}

final postOnboardingProvider =
    StateNotifierProvider<PostOnboardingNotifier, bool>(
  (_) => PostOnboardingNotifier(),
);
