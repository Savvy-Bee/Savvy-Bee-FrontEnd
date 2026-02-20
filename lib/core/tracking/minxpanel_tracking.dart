import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter/foundation.dart';

/// Lightweight Mixpanel service for core V1 tracking.
/// Covers: Signup, First Feature, Quiz, AI, Sessions, Funnels.
class MixpanelService {
  static Mixpanel? _mixpanel;
  static String? _userId;

  /// Initialize Mixpanel with your project token.
  /// Call this in main() before runApp().
  static Future<void> initialize(String projectToken) async {
    try {
      _mixpanel = await Mixpanel.init(
        projectToken,
        trackAutomaticEvents: false, // We track sessions manually
      );
      if (kDebugMode) print('✓ Mixpanel initialized');
    } catch (e) {
      if (kDebugMode) print('✗ Mixpanel init failed: $e');
    }
  }

  /// Identify the user and set one-time properties.
  /// Call after successful signup or login.
  static Future<void> identifyUser({
    required String userId,
    required String email,
    required DateTime signupDate,
    required String acquisitionSource,
  }) async {
    if (_mixpanel == null) return;

    _userId = userId;
    _mixpanel!.identify(userId);

    // Set user properties (these persist)
    _mixpanel!.getPeople().set('email', email);
    _mixpanel!.getPeople().set('signup_date', signupDate.toIso8601String());
    _mixpanel!.getPeople().set('acquisition_source', acquisitionSource);
    
    if (kDebugMode) print('✓ User identified: $userId');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. SIGNUP TRACKING ✅
  // ═══════════════════════════════════════════════════════════════════════════

  /// Track successful user signup.
  /// Call this after registration is complete (email verified + details saved).
  static Future<void> trackSignup(String acquisitionSource) async {
    await _track('USER_SIGNED_UP', {
      'acquisition_source': acquisitionSource,
    });
  }
  
  static Future<void> trackLogin(String acquisitionSource) async {
    await _track('USER_LOGGED_IN', {
      'acquisition_source': acquisitionSource,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. FIRST FEATURE USED ✅
  // ═══════════════════════════════════════════════════════════════════════════

  /// Track the first time a user engages with a major feature.
  /// feature_name: 'Hive' | 'Tools' | 'Game' | 'NAHL'
  /// 
  /// Call this once per user, as soon as they interact with any feature.
  static Future<void> trackFirstFeatureUsed(String featureName) async {
    // Check if we've already tracked this (use local flag or server-side check)
    // For simplicity, always fire it — Mixpanel funnels handle duplicates.
    await _track('FIRST_MEANINGFUL_ACTION', {
      'feature_name': featureName,
    });
    
    // Update user property so you can segment by first feature
    _mixpanel?.getPeople().set('first_feature_used', featureName);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. QUIZ TRACKING ✅
  // ═══════════════════════════════════════════════════════════════════════════

  /// Track when a user starts a quiz module.
  /// moduleName: 'Budgeting' | 'Numeracy' | 'Savings' | <your course titles>
  static Future<void> trackQuizStarted(String moduleName) async {
    await _track('QUIZ_STARTED', {
      'module_name': moduleName,
    });
  }

  /// Track when a user completes a quiz module.
  /// completionTimeSeconds: how long it took (will be bucketed in Mixpanel)
  static Future<void> trackQuizCompleted(
    String moduleName,
    int completionTimeSeconds,
  ) async {
    final bucket = _getTimeBucket(completionTimeSeconds);

    await _track('QUIZ_COMPLETED', {
      'module_name': moduleName,
      'completion_time_bucket': bucket,
      'completion_time_seconds': completionTimeSeconds,
    });

    // Increment total quizzes completed for this user
    _mixpanel?.getPeople().increment('total_quizzes_completed', 1.0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. AI USAGE BASIC ✅
  // ═══════════════════════════════════════════════════════════════════════════

  /// Track when a user sends a message to the AI assistant.
  /// category: 'Healing' | 'Financial_Analysis' | 'Receipt_Scan' | 'General'
  static Future<void> trackAIMessageSent({
    required String category,
    required int promptLength,
  }) async {
    final bucket = _getPromptLengthBucket(promptLength);

    await _track('NAHL_MESSAGE_SENT', {
      'message_category': category,
      'prompt_length_bucket': bucket,
      'prompt_length': promptLength,
    });

    _mixpanel?.getPeople().increment('total_nahl_messages', 1.0);
  }

  /// Track when the AI generates a response (for cost tracking).
  /// tokenCount: approximate tokens used in the response
  /// costEstimate: estimated cost in USD cents (e.g., 5 = $0.05)
  static Future<void> trackAIResponseGenerated({
    required int tokenCount,
    required int costEstimate,
    required int processingTimeMs,
  }) async {
    final tokenBucket = _getTokenBucket(tokenCount);
    final costBucket = _getCostBucket(costEstimate);
    final timeBucket = _getProcessingTimeBucket(processingTimeMs);

    await _track('NAHL_RESPONSE_GENERATED', {
      'token_usage_bucket': tokenBucket,
      'cost_estimate_bucket': costBucket,
      'processing_time_bucket': timeBucket,
      'token_count': tokenCount,
      'cost_estimate_cents': costEstimate,
      'processing_time_ms': processingTimeMs,
    });

    // Accumulate AI cost and token usage for this user
    _mixpanel?.getPeople().increment('ai_token_usage_total', tokenCount.toDouble());
    _mixpanel?.getPeople().increment('ai_cost_estimate_total', costEstimate.toDouble());
  }

  /// Track when a receipt scan is completed.
  /// complexity: 'Low' | 'Medium' | 'High' (based on item count or processing time)
  static Future<void> trackReceiptScanCompleted({
    required String complexity,
    required int costEstimate,
  }) async {
    final costBucket = _getCostBucket(costEstimate);

    await _track('NAHL_RECEIPT_SCAN_COMPLETED', {
      'scan_complexity_bucket': complexity,
      'cost_estimate_bucket': costBucket,
      'cost_estimate_cents': costEstimate,
    });

    _mixpanel?.getPeople().increment('total_receipt_scans', 1.0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. SESSION TRACKING ✅
  // ═══════════════════════════════════════════════════════════════════════════

  /// Track when a user starts a session (app opened or resumed).
  static Future<void> trackSessionStarted() async {
    await _track('USER_SESSION_STARTED', {});
    _mixpanel?.getPeople().increment('total_sessions', 1.0);
  }

  /// Track when a user ends a session (app backgrounded or closed).
  /// sessionDurationSeconds: how long the session lasted
  static Future<void> trackSessionEnded(int sessionDurationSeconds) async {
    final bucket = _getSessionDurationBucket(sessionDurationSeconds);

    await _track('USER_SESSION_ENDED', {
      'session_duration_bucket': bucket,
      'session_duration_seconds': sessionDurationSeconds,
    });

    // Update last active date
    _mixpanel?.getPeople().set(
      'last_active_date',
      DateTime.now().toIso8601String(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. FUNNELS POSSIBLE ✅
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // Mixpanel funnels are created in the UI by selecting event sequences, e.g.:
  //   1. USER_SIGNED_UP
  //   2. FIRST_MEANINGFUL_ACTION
  //   3. QUIZ_STARTED
  //   4. QUIZ_COMPLETED
  //
  // No additional code needed here — just ensure the events above fire correctly.

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Internal method to send an event to Mixpanel.
  static Future<void> _track(String eventName, Map<String, dynamic> properties) async {
    if (_mixpanel == null) {
      if (kDebugMode) print('⚠ Mixpanel not initialized, skipping: $eventName');
      return;
    }

    try {
      await _mixpanel!.track(eventName, properties: properties);
      if (kDebugMode) print('✓ Tracked: $eventName');
    } catch (e) {
      if (kDebugMode) print('✗ Track failed: $eventName - $e');
    }
  }

  /// Bucket completion time into Fast/Medium/Slow.
  static String _getTimeBucket(int seconds) {
    if (seconds < 60) return 'Fast';
    if (seconds < 300) return 'Medium';
    return 'Slow';
  }

  /// Bucket prompt length into Short/Medium/Long.
  static String _getPromptLengthBucket(int length) {
    if (length < 50) return 'Short';
    if (length < 200) return 'Medium';
    return 'Long';
  }

  /// Bucket token count into Low/Medium/High.
  static String _getTokenBucket(int tokens) {
    if (tokens < 500) return 'Low';
    if (tokens < 2000) return 'Medium';
    return 'High';
  }

  /// Bucket cost estimate (in cents) into Low/Medium/High.
  static String _getCostBucket(int cents) {
    if (cents < 10) return 'Low'; // < $0.10
    if (cents < 50) return 'Medium'; // $0.10 - $0.50
    return 'High'; // > $0.50
  }

  /// Bucket processing time (in ms) into Short/Medium/Long.
  static String _getProcessingTimeBucket(int ms) {
    if (ms < 1000) return 'Short';
    if (ms < 5000) return 'Medium';
    return 'Long';
  }

  /// Bucket session duration (in seconds) into Short/Medium/Long.
  static String _getSessionDurationBucket(int seconds) {
    if (seconds < 60) return 'Short'; // < 1 min
    if (seconds < 600) return 'Medium'; // 1-10 min
    return 'Long'; // > 10 min
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OPTIONAL: Flush and reset
  // ═══════════════════════════════════════════════════════════════════════════

  /// Flush all pending events to Mixpanel (call before app exit if needed).
  static Future<void> flush() async {
    await _mixpanel?.flush();
  }

  /// Reset Mixpanel state (call on logout).
  static Future<void> reset() async {
    await _mixpanel?.reset();
    _userId = null;
    if (kDebugMode) print('✓ Mixpanel reset');
  }
}