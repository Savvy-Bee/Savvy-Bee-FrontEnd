// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:savvy_bee_mobile/core/services/push_notification_service.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/tracking/analytics_service.dart';
import 'package:savvy_bee_mobile/core/tracking/minxpanel_tracking.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/providers/biometric_provider.dart';
import 'features/auth/presentation/screens/biometric_lock_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait lock and system UI overlay only apply on mobile
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // Firebase: temporarily disabled
  // try {
  //   final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  //   if (firebaseOptions != null) {
  //     await Firebase.initializeApp(options: firebaseOptions);
  //     if (!kIsWeb) {
  //       await PushNotificationService.instance.initialize();
  //     }
  //     final token = await FirebaseMessaging.instance.getToken();
  //     debugPrint("FCM TOKEN: $token");
  //   }
  // } catch (error, stackTrace) {
  //   debugPrint('Firebase init failed: $error');
  //   debugPrintStack(stackTrace: stackTrace);
  // }

  // RevenueCat (purchases_flutter) is not supported on web
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: ".env");
      final apiKey = dotenv.env[Constants.revenueCatApiKey]!;
      await Purchases.configure(PurchasesConfiguration(apiKey));
    } catch (_) {}
  }

  // Initialize Mixpanel BEFORE runApp()
  // await MixpanelService.initialize('0b9bfa95112c6154772de9e7adfde75b');
  // await AnalyticsService.initialize();

  runApp(
    ScreenUtilInit(
      designSize: const Size(402, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const ProviderScope(child: SavvyBeeApp()),
    ),
  );
}

class SavvyBeeApp extends ConsumerStatefulWidget {
  const SavvyBeeApp({super.key});

  @override
  ConsumerState<SavvyBeeApp> createState() => _SavvyBeeAppState();
}

class _SavvyBeeAppState extends ConsumerState<SavvyBeeApp>
    with WidgetsBindingObserver {
  // Track lifecycle so we only show the lock when coming back FROM background
  AppLifecycleState? _previousState;

  // ── Session timing ────────────────────────────────────────────────────────
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cold-start counts as a session start.
    _sessionStart = DateTime.now();
    AnalyticsService.trackSessionStarted();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App going to background — end the current session.
        if (_sessionStart != null) {
          final duration = DateTime.now().difference(_sessionStart!).inSeconds;
          AnalyticsService.trackSessionEnded(duration);
          _sessionStart = null;
        }

      case AppLifecycleState.resumed:
        if (_previousState == AppLifecycleState.paused) {
          // App returning from background — start a new session.
          _sessionStart = DateTime.now();
          AnalyticsService.trackSessionStarted();
          _onAppResumed();
        }

      default:
        break;
    }
    _previousState = state;
  }

  void _onAppResumed() {
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    final biometric = ref.read(biometricProvider);

    // Don't stack lock screens if already on one
    final currentLocation =
        appRouter.routerDelegate.currentConfiguration.uri.toString();
    if (currentLocation == BiometricLockScreen.path) return;

    if (isAuthenticated && biometric.isEnabled && biometric.isAvailable) {
      appRouter.go(BiometricLockScreen.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Savvy Bee',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        const maxWidth = 480.0;

        if (screenWidth > maxWidth) {
          return Container(
            color: AppColors.greyLight,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        }

        return child!;
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:savvy_bee_mobile/core/services/notification_service.dart';
// import 'core/theme/app_theme.dart';
// import 'core/routing/app_router.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'core/utils/constants.dart';
// import 'firebase_options.dart'; // This will be generated

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//       systemNavigationBarColor: Colors.transparent,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ),
//   );

//   try {
//     await dotenv.load(fileName: ".env");

//     final apiKey = dotenv.env[Constants.revenueCatApiKey]!;
//     await Purchases.configure(PurchasesConfiguration(apiKey));
//   } catch (_) {}

//   // Initialize Firebase
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
    
//     // Initialize notification service
//     final notificationService = NotificationService();
//     await notificationService.initialize();
//   } catch (e) {
//     print('Error initializing Firebase/Notifications: $e');
//   }

//   runApp(
//     ScreenUtilInit(
//       designSize: const Size(402, 874),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) => const ProviderScope(child: SavvyBeeApp()),
//     ),
//   );
// }

// class SavvyBeeApp extends StatelessWidget {
//   const SavvyBeeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'Savvy Bee',
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: ThemeMode.light,
//       routerConfig: appRouter,
//       debugShowCheckedModeBanner: false,
//       builder: (context, child) {
//         final screenWidth = MediaQuery.of(context).size.width;
//         const maxWidth = 480.0;

//         if (screenWidth > maxWidth) {
//           return Container(
//             color: AppColors.greyLight,
//             child: Center(
//               child: Container(
//                 constraints: const BoxConstraints(maxWidth: maxWidth),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.1),
//                       blurRadius: 20,
//                       spreadRadius: 0,
//                     ),
//                   ],
//                 ),
//                 child: child,
//               ),
//             ),
//           );
//         }

//         return child!;
//       },
//     );
//   }
// }
