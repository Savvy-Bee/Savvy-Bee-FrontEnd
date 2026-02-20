import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/tracking/minxpanel_tracking.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: ".env");

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

  try {
    await dotenv.load(fileName: ".env");

    final apiKey = dotenv.env[Constants.revenueCatApiKey]!;
    await Purchases.configure(PurchasesConfiguration(apiKey));
  } catch (_) {}

    // Initialize Mixpanel BEFORE runApp()
  await MixpanelService.initialize('0b9bfa95112c6154772de9e7adfde75b');

  runApp(
    ScreenUtilInit(
      designSize: const Size(402, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const ProviderScope(child: SavvyBeeApp()),
    ),
  );
}

class SavvyBeeApp extends StatelessWidget {
  const SavvyBeeApp({super.key});

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
            color: AppColors.greyLight, // Background color for sides
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