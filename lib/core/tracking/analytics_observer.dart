import 'package:flutter/material.dart';
import 'analytics_service.dart';

/// go_router-compatible [NavigatorObserver] that fires a [AnalyticsEvents.screenViewed]
/// event on every push, pop, and replace.
///
/// Register in app_router.dart:
/// ```dart
/// final GoRouter appRouter = GoRouter(
///   observers: [AppAnalyticsObserver()],
///   ...
/// );
/// ```
class AppAnalyticsObserver extends NavigatorObserver {
  /// Routes that should NOT be tracked (e.g. transparent overlays, bottom sheets).
  static const _ignored = {'/biometric-lock'};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // When popping, the user is returning to previousRoute.
    if (previousRoute != null) _track(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _track(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _track(previousRoute);
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    if (_ignored.contains(name)) return;

    // Strip leading slash for readability in Mixpanel: '/home' → 'home'
    final screen = name.startsWith('/') ? name.substring(1) : name;
    AnalyticsService.trackScreenViewed(
      screen.isEmpty ? 'root' : screen,
    );
  }
}
