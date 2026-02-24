import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budgets_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goals_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/taxation/taxation_dashboard_screen.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  static const String path = '/tools';

  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger fetch after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(homeDataProvider);
    });
  }

  String _getHealthImage(String status) {
    final normalizedStatus = status.toLowerCase().trim();

    switch (normalizedStatus) {
      case 'stabilizing':
        return 'assets/images/Financial_Health/JARS/HIVE BAR STABILISING.png';
      case 'surviving':
        return 'assets/images/Financial_Health/JARS/HIVE BAR SURVIVING.png';
      case 'flourishing':
        return 'assets/images/Financial_Health/JARS/HIVE BAR FLOURISHING.png';
      case 'thriving':
        return 'assets/images/Financial_Health/JARS/HIVE BAR THRIVING.png';
      case 'building':
        return 'assets/images/Financial_Health/JARS/HIVE BAR BUILDING.png';
      default:
        return 'assets/images/Financial_Health/JARS/HIVE BAR EMPTY.png';
    }
  }

  String _getPopUpImage(String status) {
    final normalizedStatus = status.toLowerCase().trim();

    switch (normalizedStatus) {
      case 'stabilizing':
        return 'assets/images/illustrations/health/stabilizing.png';
      case 'surviving':
        return 'assets/images/illustrations/health/surviving.png';
      case 'flourishing':
        return 'assets/images/illustrations/health/flourishing.png';
      case 'thriving':
        return 'assets/images/illustrations/health/thriving.png';
      case 'building':
        return 'assets/images/illustrations/health/building.png';
      default:
        return 'assets/images/illustrations/health/stabilizing.png';
    }
  }

  void _showHealthPopup(String statusText) {
    final popupImage = _getPopUpImage(statusText);

    showDialog(
      context: context,
      barrierDismissible: true, // Allow tapping outside to close
      barrierColor: Colors.black.withOpacity(
        0.7,
      ), // Semi-transparent background
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Close on tap
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              // Align(
              //   alignment: Alignment.topRight,
              //   child: IconButton(
              //     onPressed: () => Navigator.of(context).pop(),
              //     icon: const Icon(Icons.close, color: Colors.white, size: 32),
              //     style: IconButton.styleFrom(
              //       backgroundColor: Colors.black.withOpacity(0.5),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 16),

              // Health status image
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(popupImage, fit: BoxFit.contain),
                ),
              ),

              const SizedBox(height: 16),

              // Status text
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 24,
              //     vertical: 12,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(24),
              //   ),
              //   child: Text(
              //     statusText.toUpperCase(),
              //     style: const TextStyle(
              //       fontFamily: 'GeneralSans',
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.black,
              //       letterSpacing: 1.2,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);

    // Fallback name until data loads
    final firstName = homeDataAsync.valueOrNull?.data?.firstName ?? '';

    final isLoading = homeDataAsync.isLoading && !homeDataAsync.hasValue;
    final hasError = homeDataAsync.hasError;

    final healthData = homeDataAsync.valueOrNull?.data?.aiData;
    final statusText = healthData?.status ?? '';

    return Scaffold(
      appBar: _buildAppBar(firstName, statusText, context),
      body: Stack(
        children: [
          // ── Main content ── always visible ───────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tools',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 1.1,
                        ),
                      ),
                      const Gap(8),
                      const Text(
                        'Your one stop shop for peak financial health',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tools list
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      children: [
                        _buildToolItem(
                          title: 'Budgets',
                          subtitle:
                              'Create smart budgets, track spending, and get personalized insights.',
                          iconPath: 'assets/images/icons/budget_icon.png',
                          onPressed: () =>
                              context.pushNamed(BudgetsScreen.path),
                        ),
                        const Divider(color: AppColors.grey, height: 1),
                        _buildToolItem(
                          title: 'Goals',
                          subtitle:
                              'Set goals, get AI-powered suggestions, and track your progress.',
                          iconPath: 'assets/images/icons/goals_icon.png',
                          onPressed: () => context.pushNamed(GoalsScreen.path),
                        ),
                        const Divider(color: AppColors.grey, height: 1),
                        _buildToolItem(
                          title: 'Debt Tracker',
                          subtitle:
                              'Stay on top of your debts and plan your payoff with ease.',
                          iconPath: 'assets/images/icons/debt_icon.png',
                          onPressed: () => context.pushNamed(DebtScreen.path),
                        ),
                        const Divider(color: AppColors.grey, height: 1),
                        _buildToolItem(
                          title: 'Tax',
                          subtitle:
                              'Calculate your tax and track your earnings with ease.',
                          iconPath: 'assets/images/icons/tax_icon.png',
                          onPressed: () =>
                              context.pushNamed(TaxationDashboardScreen.path),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Small loading indicator (only during initial fetch) ───────────
          if (isLoading)
            const Positioned(
              top: 16,
              right: 24,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              ),
            ),

          // ── Error overlay ── only shown on real error ────────────────────
          if (hasError)
            CustomErrorWidget(
              icon: Icons.person_outline,
              title: 'Unable to Load User Info',
              subtitle:
                  'We couldn’t fetch your account data. Please check your connection and try again.',
              actionButtonText: 'Retry',
              onActionPressed: () {
                ref.invalidate(homeDataProvider);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildToolItem({
    required String title,
    required String subtitle,
    required String iconPath,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 37,
                  height: 37,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    String firstName,
    String statusText,
    BuildContext context,
  ) {
    final healthImage = _getHealthImage(statusText);
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => context.pushNamed(ChatScreen.path),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/topbar/nav-left-icon.png',
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Chat with Nahl',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 25),
              Image.asset(
                'assets/images/topbar/nav-center-icon.png',
                width: 30,
                height: 32,
                fit: BoxFit.contain,
              ),
            ],
          ),

          // Right side - profile avatar
          GestureDetector(
            onTap: () => context.pushNamed(ProfileScreen.path),
            child: Row(
              children: [
                // JAR IMAGE - Clickable to show popup
                InkWell(
                  onTap: () => _showHealthPopup(statusText),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      healthImage,
                      width: 60,
                      height: 62,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      firstName.isNotEmpty
                          ? (firstName.length > 1
                                ? firstName.substring(0, 2).toUpperCase()
                                : firstName[0].toUpperCase())
                          : 'Me',
                      style: const TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
// import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budgets_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goals_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/taxation/taxation_dashboard_screen.dart';

// import 'budget/budget_screen.dart';

// class ToolsScreen extends ConsumerStatefulWidget {
//   static const String path = '/tools';

//   const ToolsScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ToolsScreenState();
// }

// class _ToolsScreenState extends ConsumerState<ToolsScreen> {
//   @override
//   void initState() {
//     super.initState();

//     // Fetch home data when screen opens
//     // WidgetsBinding ensures it runs after the first frame is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.invalidate(homeDataProvider);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final homeData = ref.watch(homeDataProvider);

//     return homeData.when(
//       skipLoadingOnRefresh: false,
//       data: (value) {
//         final data = value.data;

//         return Scaffold(
//           appBar: _buildAppBar(data.firstName, context),
//           body: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.topRight,
//                 colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header section
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Tools',
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontFamily: 'GeneralSans',
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                           height: 1.1,
//                         ),
//                       ),
//                       const Gap(8),
//                       Text(
//                         'Your one stop shop for peak financial health',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontFamily: 'GeneralSans',
//                           fontWeight: FontWeight.w400,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Tools list section
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(32),
//                       ),
//                     ),
//                     child: ListView(
//                       padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
//                       children: [
//                         _buildToolItem(
//                           title: 'Budgets',
//                           subtitle:
//                               'Create smart budgets, track spending, and get personalized insights.',
//                           iconPath: 'assets/images/icons/budget_icon.png',
//                           onPressed: () =>
//                               context.pushNamed(BudgetsScreen.path),
//                         ),
//                         Divider(
//                           color: AppColors.grey.withValues(alpha: 0.2),
//                           height: 1,
//                         ),
//                         _buildToolItem(
//                           title: 'Goals',
//                           subtitle:
//                               'Set goals, get AI-powered suggestions, and track your progress.',
//                           iconPath: 'assets/images/icons/goals_icon.png',
//                           onPressed: () => context.pushNamed(GoalsScreen.path),
//                         ),
//                         Divider(
//                           color: AppColors.grey.withValues(alpha: 0.2),
//                           height: 1,
//                         ),
//                         _buildToolItem(
//                           title: 'Debt Tracker',
//                           subtitle:
//                               'Stay on top of your debts and plan your payoff with ease.',
//                           iconPath: 'assets/images/icons/debt_icon.png',
//                           onPressed: () => context.pushNamed(DebtScreen.path),
//                         ),
//                         Divider(
//                           color: AppColors.grey.withValues(alpha: 0.2),
//                           height: 1,
//                         ),
//                         _buildToolItem(
//                           title: 'Tax',
//                           subtitle:
//                               'Calculate your tax and track you earnings with ease.',
//                           iconPath: 'assets/images/icons/tax_icon.png',
//                           onPressed: () =>
//                               context.pushNamed(TaxationDashboardScreen.path),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//       error: (error, stackTrace) => Scaffold(
//         body: CustomErrorWidget(
//           icon: Icons.person_outline,
//           title: 'Unable to Load User Info',
//           subtitle:
//               'We couldn\'t fetch your account data. Please check your connection and try again.',
//           actionButtonText: 'Retry',
//           onActionPressed: () {
//             ref.invalidate(homeDataProvider);
//           },
//         ),
//       ),
//       loading: () => Scaffold(
//         body: CustomLoadingWidget(text: 'Loading your account info...'),
//       ),
//     );
//   }

//   Widget _buildToolItem({
//     required String title,
//     required String subtitle,
//     required String iconPath,
//     VoidCallback? onPressed,
//   }) {
//     return InkWell(
//       onTap: onPressed,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         child: Row(
//           children: [
//             // Icon container
//             Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: AppColors.grey.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Center(
//                 child: Image.asset(
//                   iconPath,
//                   width: 37,
//                   height: 37,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             const Gap(16),
//             // Text content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontFamily: 'GeneralSans',
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const Gap(4),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontFamily: 'GeneralSans',
//                       fontWeight: FontWeight.w400,
//                       color: AppColors.grey,
//                       height: 1,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Gap(8),
//             // Arrow icon
//             Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
//           ],
//         ),
//       ),
//     );
//   }

//   AppBar _buildAppBar(String firstName, BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.topRight,
//             colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
//           ),
//         ),
//       ),
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // LEFT
//           GestureDetector(
//             onTap: () {},
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 InkWell(
//                   onTap: () => context.pushNamed(ChatScreen.path),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 32,
//                         height: 32,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: AppColors.primary),
//                         ),
//                         child: Center(
//                           child: Image.asset(
//                             'assets/images/topbar/nav-left-icon.png',
//                             width: 32,
//                             height: 32,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       const Text(
//                         'Chat with Nahl',
//                         style: TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(width: 25),

//                 Image.asset(
//                   'assets/images/topbar/nav-center-icon.png',
//                   width: 30,
//                   height: 32,
//                   fit: BoxFit.contain,
//                 ),
//               ],
//             ),
//           ),

//           // RIGHT
//           GestureDetector(
//             onTap: () => context.pushNamed(ProfileScreen.path),
//             child: Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.black, width: 1),
//               ),
//               child: Center(
//                 child: Text(
//                   firstName.isNotEmpty
//                       ? (firstName.length > 1
//                             ? firstName.substring(0, 2).toUpperCase()
//                             : firstName[0].toUpperCase())
//                       : 'DT',
//                   style: const TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontWeight: FontWeight.w500,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       centerTitle: false,
//       automaticallyImplyLeading: false,
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
// import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budgets_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goals_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/taxation/taxation_dashboard_screen.dart';

// import 'budget/budget_screen.dart';

// class ToolsScreen extends ConsumerStatefulWidget {
//   static const String path = '/tools';

//   const ToolsScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ToolsScreenState();
// }

// class _ToolsScreenState extends ConsumerState<ToolsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final homeData = ref.watch(homeDataProvider);

//     return homeData.when(
//       skipLoadingOnRefresh: false,

//       // loading: () {
//       //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
//       // },
//       data: (value) {
//         final data = value.data;

//         return Scaffold(
//           // backgroundColor: AppColors.warning, // Yellow background
//           appBar: _buildAppBar(data.firstName, context),
//           body: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.topRight,
//                 colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header section
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Tools',
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontFamily: 'GeneralSans',
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                           height: 1.1,
//                         ),
//                       ),
//                       const Gap(8),
//                       Text(
//                         'Your one stop shop for peak financial health',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontFamily: 'GeneralSans',
//                           fontWeight: FontWeight.w400,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Tools list section
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(32),
//                       ),
//                     ),
//                     child: ListView(
//                       padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
//                       children: [
//                         _buildToolItem(
//                           title: 'Budgets',
//                           subtitle:
//                               'Create smart budgets, track spending, and get personalized insights.',
//                           iconPath:
//                               'assets/images/icons/budget_icon.png', // Replace with your actual icon path
//                           onPressed: () =>
//                               context.pushNamed(BudgetsScreen.path),
//                         ),
//                         Divider(
//                           color: AppColors.grey.withValues(alpha: 0.2),
//                           height: 1,
//                         ),
//                         _buildToolItem(
//                           title: 'Goals',
//                           subtitle:
//                               'Set goals, get AI-powered suggestions, and track your progress.',
//                           iconPath:
//                               'assets/images/icons/goals_icon.png', // Replace with your actual icon path
//                           onPressed: () => context.pushNamed(GoalsScreen.path),
//                         ),
//                         Divider(
//                           color: AppColors.grey.withValues(alpha: 0.2),
//                           height: 1,
//                         ),
//                         _buildToolItem(
//                           title: 'Debt Tracker',
//                           subtitle:
//                               'Stay on top of your debts and plan your payoff with ease.',
//                           iconPath:
//                               'assets/images/icons/debt_icon.png', // Replace with your actual icon path
//                           onPressed: () => context.pushNamed(DebtScreen.path),
//                         ),
//                         Divider(
//                           color: AppColors.grey.withValues(alpha: 0.2),
//                           height: 1,
//                         ),
//                         _buildToolItem(
//                           title: 'Tax',
//                           subtitle:
//                               'Calculate your tax and track you earnings with ease.',
//                           iconPath:
//                               'assets/images/icons/tax_icon.png', // Replace with your actual icon path
//                           onPressed: () =>
//                               // ScaffoldMessenger.of(context).showSnackBar(
//                               //   const SnackBar(content: Text('Coming soon')),
//                               // ),
//                           context.pushNamed(TaxationDashboardScreen.path),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//       error: (error, stackTrace) => Scaffold(
//         body: CustomErrorWidget(
//           icon: Icons.person_outline,
//           title: 'Unable to Load User Info',
//           subtitle:
//               'We couldn\'t fetch your account data. Please check your connection and try again.',
//           actionButtonText: 'Retry',
//           onActionPressed: () {
//             ref.invalidate(homeDataProvider);
//           },
//         ),
//       ),
//       loading: () => Scaffold(
//         body: CustomLoadingWidget(text: 'Loading your account info...'),
//       ),
//     );
//   }

//   Widget _buildToolItem({
//     required String title,
//     required String subtitle,
//     required String iconPath,
//     VoidCallback? onPressed,
//   }) {
//     return InkWell(
//       onTap: onPressed,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         child: Row(
//           children: [
//             // Icon container
//             Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: AppColors.grey.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Center(
//                 child: Image.asset(
//                   iconPath,
//                   width: 37,
//                   height: 37,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             const Gap(16),
//             // Text content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontFamily: 'GeneralSans',
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const Gap(4),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontFamily: 'GeneralSans',
//                       fontWeight: FontWeight.w400,
//                       color: AppColors.grey,
//                       height: 1,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Gap(8),
//             // Arrow icon
//             Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
//           ],
//         ),
//       ),
//     );
//   }

//   AppBar _buildAppBar(String firstName, BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent, // important
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.topRight, // left → right
//             colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
//           ),
//         ),
//       ),
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // LEFT
//           GestureDetector(
//             onTap: () {
//               // Navigator.push(...)
//             },
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 InkWell(
//                   onTap: () => context.pushNamed(ChatScreen.path),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 32,
//                         height: 32,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: AppColors.primary),
//                         ),
//                         child: Center(
//                           child: Image.asset(
//                             'assets/images/topbar/nav-left-icon.png',
//                             width: 32,
//                             height: 32,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       const Text(
//                         'Chat with Nahl',
//                         style: TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(width: 25),

//                 Image.asset(
//                   'assets/images/topbar/nav-center-icon.png',
//                   width: 30,
//                   height: 32,
//                   fit: BoxFit.contain,
//                 ),
//               ],
//             ),
//           ),

//           // RIGHT
//           GestureDetector(
//             onTap: () => context.pushNamed(ProfileScreen.path),
//             child: Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.black, width: 1),
//               ),
//               child: Center(
//                 child: Text(
//                   firstName.isNotEmpty
//                       ? (firstName.length > 1
//                             ? firstName.substring(0, 2).toUpperCase()
//                             : firstName[0].toUpperCase())
//                       : 'DT',
//                   style: const TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontWeight: FontWeight.w500,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       centerTitle: false,
//       automaticallyImplyLeading: false,
//     );
//   }
// }