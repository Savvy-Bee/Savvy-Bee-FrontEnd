import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/health_card.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/tools_screen.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../home/presentation/providers/home_data_provider.dart';

class FinancialHealthScreen extends ConsumerStatefulWidget {
  static const String path = '/financia;-health';

  const FinancialHealthScreen({super.key}); 

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialHealthScreenState();
}

class _FinancialHealthScreenState extends ConsumerState<FinancialHealthScreen> {
  // Screenshot controller
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  /// Capture and share the financial health card
  Future<void> _shareHealthCard() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      // Capture the widget as image
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0, // High quality image
      );

      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/financial_health.png');
      await file.writeAsBytes(imageBytes);

      // Share the image with text
      final homeData = ref.read(homeDataProvider).value;
      final status = homeData?.data.aiData.status ?? 'Financial Health';

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '''
🐝 My Financial Health with SavvyBee!

Status: $status

Track your financial health journey with SavvyBee!
''',
        subject: 'My Financial Health - SavvyBee',
      );

      if (mounted) {
        CustomSnackbar.show(
          context,
          'Health card shared successfully!',
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      debugPrint('Error sharing health card: $e');
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to share health card',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.financialHealthBg,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(homeDataProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: AppColors.financialHealthBg,
      body: homeData.when(
        skipLoadingOnRefresh: false,
        data: (data) {
          final healthData = data.data.aiData;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),

                // Wrap HealthCardWidget with Screenshot widget
                Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    color: AppColors.financialHealthBg, // Match background
                    child: HealthCardWidget(
                      statusText: healthData.status,
                      descriptionText: healthData.message,
                      rating: healthData.ratings.toDouble(),
                    ),
                  ),
                ),

                Row(
                  spacing: 8,
                  children: [
                    ShareButton(
                      onPressed: _isSharing ? null : _shareHealthCard,
                      // isLoading: _isSharing, // If ShareButton supports loading
                    ),
                    Expanded(
                      flex: 2,
                      child: CustomElevatedButton(
                        text: 'Fix your financial health',
                        isGamePlay: true,
                        onPressed: () => context.go(ToolsScreen.path),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => CustomErrorWidget.error(
          onRetry: () => ref.invalidate(homeDataProvider),
        ),
        loading: () => Center(
          child: Text(
            'Loading...',
            style: TextStyle(
              fontSize: 40,
              color: AppColors.primaryFaint,
              fontFamily: Constants.fredokaFontFamily,
              letterSpacing: 40 * 0.02,
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/widgets/health_card.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/tools_screen.dart';

// import '../../../home/presentation/providers/home_data_provider.dart';

// class FinancialHealthScreen extends ConsumerStatefulWidget { 
//   static const String path = '/financia;-health';

//   const FinancialHealthScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _FinancialHealthScreenState();
// }

// class _FinancialHealthScreenState extends ConsumerState<FinancialHealthScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final homeData = ref.watch(homeDataProvider);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.financialHealthBg,
//         foregroundColor: AppColors.white,
//         actions: [
//           IconButton(
//             onPressed: () => ref.invalidate(homeDataProvider),
//             icon: Icon(Icons.refresh),
//           ),
//         ],
//       ),
//       backgroundColor: AppColors.financialHealthBg,
//       body: homeData.when(
//         skipLoadingOnRefresh: false,
//         data: (data) {
//           final healthData = data.data.aiData;
//           return Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const SizedBox(),
//                 HealthCardWidget(
//                   statusText: healthData.status,
//                   descriptionText: healthData.message,
//                   rating: healthData.ratings.toDouble(),
//                 ),
//                 Row(
//                   spacing: 8,
//                   children: [
//                     ShareButton(onPressed: () {}),
//                     Expanded(
//                       flex: 2,
//                       child: CustomElevatedButton(
//                         text: 'Fix your financial health',
//                         isGamePlay: true,
//                         onPressed: () => context.go(ToolsScreen.path),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//         error: (error, stackTrace) => CustomErrorWidget.error(
//           onRetry: () => ref.invalidate(homeDataProvider),
//         ),
//         loading: () => Center(
//           child: Text(
//             'Loading...',
//             style: TextStyle(
//               fontSize: 40,
//               color: AppColors.primaryFaint,
//               fontFamily: Constants.fredokaFontFamily,
//               letterSpacing: 40 * 0.02
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
