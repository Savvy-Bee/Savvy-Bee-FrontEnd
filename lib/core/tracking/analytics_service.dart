import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'minxpanel_tracking.dart';

// ─── Event name constants ─────────────────────────────────────────────────────

/// All Mixpanel event names in one place.
/// Use these instead of bare strings to prevent typos.
abstract class AnalyticsEvents {
  // Auth
  static const String userSignedUp = 'USER_SIGNED_UP';
  static const String userLoggedIn = 'USER_LOGGED_IN';
  static const String userLoggedOut = 'USER_LOGGED_OUT';
  static const String passwordResetRequested = 'PASSWORD_RESET_REQUESTED';

  // Onboarding
  static const String onboardingStepCompleted = 'ONBOARDING_STEP_COMPLETED';
  static const String onboardingSkipped = 'ONBOARDING_SKIPPED';
  static const String onboardingCompleted = 'ONBOARDING_COMPLETED';
  static const String postOnboardingCompleted = 'POST_ONBOARDING_COMPLETED';
  static const String postOnboardingSkipped = 'POST_ONBOARDING_SKIPPED';

  // Navigation
  static const String screenViewed = 'SCREEN_VIEWED';

  // Interaction
  static const String buttonTapped = 'BUTTON_TAPPED';
  static const String featureAccessed = 'FEATURE_ACCESSED';
  static const String itemSelected = 'ITEM_SELECTED';

  // Content
  static const String lessonStarted = 'LESSON_STARTED';
  static const String lessonCompleted = 'LESSON_COMPLETED';
  static const String lessonShared = 'LESSON_SHARED';
  static const String quizStarted = 'QUIZ_STARTED';
  static const String quizCompleted = 'QUIZ_COMPLETED';

  // AI
  static const String aiMessageSent = 'NAHL_MESSAGE_SENT';
  static const String aiResponseGenerated = 'NAHL_RESPONSE_GENERATED';
  static const String receiptScanCompleted = 'NAHL_RECEIPT_SCAN_COMPLETED';

  // Sessions
  static const String sessionStarted = 'USER_SESSION_STARTED';
  static const String sessionEnded = 'USER_SESSION_ENDED';

  // Errors
  static const String errorOccurred = 'ERROR_OCCURRED';
}

// ─── Analytics Service ────────────────────────────────────────────────────────

/// Unified analytics facade that wraps [MixpanelService].
///
/// Every event is automatically enriched with:
///   • user_id    — set after login via [setUserId]
///   • screen     — current route, updated by [AppAnalyticsObserver]
///   • timestamp  — UTC ISO-8601
///   • platform   — android | ios | web
///   • app_version
///
/// Usage:
///   AnalyticsService.trackButtonTapped('Continue', screen: 'login');
class AnalyticsService {
  AnalyticsService._();

  static String? _userId;
  static String _currentScreen = 'unknown';
  static String _appVersion = '';
  static String _platform = '';

  // ─── Initialisation ──────────────────────────────────────────────────────────

  /// Call once in main() after MixpanelService.initialize().
  static Future<void> initialize() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {
      _appVersion = 'unknown';
    }

    if (kIsWeb) {
      _platform = 'web';
    } else if (Platform.isAndroid) {
      _platform = 'android';
    } else if (Platform.isIOS) {
      _platform = 'ios';
    } else {
      _platform = Platform.operatingSystem;
    }
  }

  // ─── Identity ─────────────────────────────────────────────────────────────────

  /// Set after login / identify. Cleared on logout via [reset].
  static void setUserId(String? userId) => _userId = userId;

  /// Called by [AppAnalyticsObserver] on every navigation event.
  static void setCurrentScreen(String screen) => _currentScreen = screen;

  // ─── Session ──────────────────────────────────────────────────────────────────

  /// Call when the app moves to foreground (cold start or resume).
  static Future<void> trackSessionStarted() async {
    await _track(AnalyticsEvents.sessionStarted, {});
    MixpanelService.trackSessionStarted(); // keeps the People counter
  }

  /// Call when the app moves to background.
  /// [durationSeconds] is the elapsed time since the last [trackSessionStarted].
  static Future<void> trackSessionEnded(int durationSeconds) async {
    await _track(AnalyticsEvents.sessionEnded, {
      'session_duration_seconds': durationSeconds,
      'session_duration_bucket': _durationBucket(durationSeconds),
    });
    MixpanelService.trackSessionEnded(durationSeconds);
  }

  // ─── Navigation ───────────────────────────────────────────────────────────────

  /// Automatically fired by [AppAnalyticsObserver]. Can also be called manually.
  static Future<void> trackScreenViewed(
    String screenName, {
    Map<String, dynamic>? extra,
  }) async {
    setCurrentScreen(screenName);
    await _track(AnalyticsEvents.screenViewed, {
      'screen_name': screenName,
      ...?extra,
    });
  }

  // ─── Interaction ──────────────────────────────────────────────────────────────

  /// Track any CTA or icon tap.
  ///
  ///   AnalyticsService.trackButtonTapped('Login');
  ///   AnalyticsService.trackButtonTapped('Skip', screen: 'onboarding_priority');
  static Future<void> trackButtonTapped(
    String buttonName, {
    String? screen,
    Map<String, dynamic>? extra,
  }) async {
    await _track(AnalyticsEvents.buttonTapped, {
      'button_name': buttonName,
      'screen': screen ?? _currentScreen,
      ...?extra,
    });
  }

  /// Track when the user opens a major app section for the first time
  /// (or each time, for frequency analysis).
  ///
  ///   feature: 'Hive' | 'Dashboard' | 'Chat' | 'Tools' | 'Spend'
  static Future<void> trackFeatureAccessed(
    String feature, {
    String? entryPoint,
  }) async {
    await _track(AnalyticsEvents.featureAccessed, {
      'feature_name': feature,
      if (entryPoint != null) 'entry_point': entryPoint,
    });
  }

  /// Track a list/chip/tile selection.
  ///
  ///   AnalyticsService.trackItemSelected('The saver', category: 'archetype');
  static Future<void> trackItemSelected(
    String itemName, {
    required String category,
    bool isMultiSelect = false,
    Map<String, dynamic>? extra,
  }) async {
    await _track(AnalyticsEvents.itemSelected, {
      'item_name': itemName,
      'category': category,
      'is_multi_select': isMultiSelect,
      ...?extra,
    });
  }

  // ─── Onboarding ───────────────────────────────────────────────────────────────

  /// Track each page of the pre-login onboarding (swipe screens).
  ///
  ///   stepName: 'welcome' | 'features_overview' | 'priority_select'
  static Future<void> trackOnboardingStepCompleted(
    String stepName, {
    required int stepIndex,
    required int totalSteps,
  }) async {
    await _track(AnalyticsEvents.onboardingStepCompleted, {
      'step_name': stepName,
      'step_index': stepIndex,
      'total_steps': totalSteps,
      'progress_pct': ((stepIndex / totalSteps) * 100).round(),
    });
  }

  static Future<void> trackOnboardingSkipped({required int atStep}) async {
    await _track(AnalyticsEvents.onboardingSkipped, {
      'skipped_at_step': atStep,
    });
  }

  static Future<void> trackOnboardingCompleted() async {
    await _track(AnalyticsEvents.onboardingCompleted, {});
  }

  /// Track each page of the financial archetype questionnaire (post-signup).
  ///
  ///   stepName: 'archetype' | 'priority' | 'finance_management' |
  ///             'confusing_topics' | 'challenges' | 'motivation'
  static Future<void> trackPostOnboardingStepCompleted(
    String stepName, {
    required int stepIndex,
    required int totalSteps,
    List<String> selectedValues = const [],
  }) async {
    await _track(AnalyticsEvents.onboardingStepCompleted, {
      'funnel': 'post_onboarding',
      'step_name': stepName,
      'step_index': stepIndex,
      'total_steps': totalSteps,
      'selected_count': selectedValues.length,
      if (selectedValues.isNotEmpty) 'selected_values': selectedValues,
    });
  }

  static Future<void> trackPostOnboardingCompleted({
    required String archetype,
    required List<String> priorities,
  }) async {
    await _track(AnalyticsEvents.postOnboardingCompleted, {
      'archetype': archetype,
      'priorities': priorities,
      'priorities_count': priorities.length,
    });
  }

  static Future<void> trackPostOnboardingSkipped({
    required int skippedAtPage,
  }) async {
    await _track(AnalyticsEvents.postOnboardingSkipped, {
      'skipped_at_page': skippedAtPage,
    });
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────────

  static Future<void> trackLogout() async {
    await _track(AnalyticsEvents.userLoggedOut, {});
  }

  static Future<void> trackPasswordResetRequested() async {
    await _track(AnalyticsEvents.passwordResetRequested, {});
  }

  // ─── Errors ───────────────────────────────────────────────────────────────────

  /// Track UI-visible errors (API failures, validation, etc.).
  /// Do NOT call for silent background errors — only for user-facing ones.
  ///
  ///   AnalyticsService.trackError('Login failed', type: 'auth');
  static Future<void> trackError(
    String message, {
    required String type,
    String? code,
    Map<String, dynamic>? extra,
  }) async {
    await _track(AnalyticsEvents.errorOccurred, {
      'error_message': message,
      'error_type': type,
      if (code != null) 'error_code': code,
      ...?extra,
    });
  }

  // ─── Reset ────────────────────────────────────────────────────────────────────

  /// Call on logout. Clears userId and resets Mixpanel identity.
  static Future<void> reset() async {
    _userId = null;
    _currentScreen = 'unknown';
    await MixpanelService.reset();
  }

  // ─── Internal ─────────────────────────────────────────────────────────────────

  /// Sends [eventName] to Mixpanel, automatically injecting shared properties.
  static Future<void> _track(
    String eventName,
    Map<String, dynamic> properties,
  ) async {
    final enriched = <String, dynamic>{
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'platform': _platform,
      'app_version': _appVersion,
      'screen': _currentScreen,
      if (_userId != null) 'user_id': _userId,
      ...properties, // caller props override defaults if there's a key conflict
    };

    try {
      await MixpanelService.rawTrack(eventName, enriched);
    } catch (e) {
      if (kDebugMode) debugPrint('✗ AnalyticsService._track($eventName): $e');
    }
  }

  static String _durationBucket(int seconds) {
    if (seconds < 60) return 'short';
    if (seconds < 600) return 'medium';
    return 'long';
  }
}
