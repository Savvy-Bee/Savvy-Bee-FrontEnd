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

import 'budget/budget_screen.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  static const String path = '/tools';

  const ToolsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDataProvider);

    return homeData.when(
      skipLoadingOnRefresh: false,

      // loading: () {
      //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
      // },
      data: (value) {
        final data = value.data;

        return Scaffold(
          // backgroundColor: AppColors.warning, // Yellow background
          appBar: _buildAppBar(data.firstName, context),
          body: Container(
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
                // Header section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                      Text(
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

                // Tools list section
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildToolItem(
                          title: 'Budgets',
                          subtitle:
                              'Create smart budgets, track spending, and get personalized insights.',
                          iconPath:
                              'assets/images/icons/budget_icon.png', // Replace with your actual icon path
                          onPressed: () =>
                              context.pushNamed(BudgetsScreen.path),
                        ),
                        Divider(
                          color: AppColors.grey.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        _buildToolItem(
                          title: 'Goals',
                          subtitle:
                              'Set goals, get AI-powered suggestions, and track your progress.',
                          iconPath:
                              'assets/images/icons/goals_icon.png', // Replace with your actual icon path
                          onPressed: () => context.pushNamed(GoalsScreen.path),
                        ),
                        Divider(
                          color: AppColors.grey.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        _buildToolItem(
                          title: 'Debt Tracker',
                          subtitle:
                              'Stay on top of your debts and plan your payoff with ease.',
                          iconPath:
                              'assets/images/icons/debt_icon.png', // Replace with your actual icon path
                          onPressed: () => context.pushNamed(DebtScreen.path),
                        ),
                        Divider(
                          color: AppColors.grey.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        _buildToolItem(
                          title: 'Tax',
                          subtitle:
                              'Calculate your tax and track you earnings with ease.',
                          iconPath:
                              'assets/images/icons/tax_icon.png', // Replace with your actual icon path
                          onPressed: () =>
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(content: Text('Coming soon')),
                              // ),
                          context.pushNamed(TaxationDashboardScreen.path),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) => Scaffold(
        body: CustomErrorWidget(
          icon: Icons.person_outline,
          title: 'Unable to Load User Info',
          subtitle:
              'We couldn\'t fetch your account data. Please check your connection and try again.',
          actionButtonText: 'Retry',
          onActionPressed: () {
            ref.invalidate(homeDataProvider);
          },
        ),
      ),
      loading: () => Scaffold(
        body: CustomLoadingWidget(text: 'Loading your account info...'),
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
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.1),
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
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
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
            // Arrow icon
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(String firstName, BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent, // important
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight, // left → right
            colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT
          GestureDetector(
            onTap: () {
              // Navigator.push(...)
            },
            child: Row(
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
          ),

          // RIGHT
          GestureDetector(
            onTap: () => context.pushNamed(ProfileScreen.path),
            child: Container(
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
                      : 'DT',
                  style: const TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
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
// import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
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
//     return Scaffold(
//       body: ListView(
//         shrinkWrap: true,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Tools',
//                   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   'Your one stop shop for peak financial health',
//                   style: TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           Gap(8),
//           CustomCard(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//             child: ListView(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 _buildToolItem(
//                   'Budget',
//                   'Create smart budgets, track spending, and get personalized insights.',
//                   onPressed: () => context.pushNamed(BudgetScreen.path),
//                 ),
//                 const Gap(8),
//                 _buildToolItem(
//                   'Goals',
//                   'Set goals, get AI-powered suggestions, and track your progress.',
//                   onPressed: () => context.pushNamed(GoalsScreen.path),
//                 ),
//                 const Gap(8),
//                 _buildToolItem(
//                   'Debt tracker',
//                   'Stay on top of your debts and plan your payoff with ease.',
//                   onPressed: () => context.pushNamed(DebtScreen.path),
//                 ),
//                 const Gap(8),
//                 _buildToolItem(
//                   'Tax',
//                   'Calculate your tax and track you earnings with ease.',
//                   onPressed: () =>
//                       context.pushNamed(TaxationDashboardScreen.path),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToolItem(
//     String title,
//     String subtitle, {
//     VoidCallback? onPressed,
//   }) {
//     return CustomCard(
//       padding: const EdgeInsets.all(14),
//       onTap: onPressed,
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.primaryFaint,
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: Image.asset(Assets.honeyJar4, height: 25, width: 25),
//           ),
//           const Gap(16),
//           Expanded(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 Text(subtitle, style: TextStyle(fontSize: 12, height: 1.2)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
