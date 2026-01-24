import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/app_bar_builder.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/hive_screen.dart';
import 'package:savvy_bee_mobile/features/premium/presentation/screens/premium_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spend_dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/tools_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../utils/assets/app_icons.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainWrapper extends ConsumerWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      appBar: index == 0 || index == 3 ? null : buildAppBar(context),
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        ref.watch(bottomNavIndexProvider),
        ref,
      ),
      floatingActionButton: index == 0 || index == 1
          ? GestureDetector(
              onTap: () => context.pushNamed(ChatScreen.path),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Image.asset(Illustrations.dashAvatar),
              ),
            )
          : null,
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    int selectedIndex,
    WidgetRef ref,
  ) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index != 5) ref.read(bottomNavIndexProvider.notifier).state = index;
        switch (index) {
          case 0:
            context.goNamed(HomeScreen.path);
            break;
          case 1:
            context.goNamed(DashboardScreen.path);
            break;
          case 2:
            context.goNamed(ToolsScreen.path);
            break;
          case 3:
            context.goNamed(HiveScreen.path);
            break;
          case 4:
            context.pushNamed(PremiumScreen.path);
            break;
          default:
            break;
        }
        // switch (index) {
        //   case 0:
        //     context.goNamed(HomeScreen.path);
        //     break;
        //   case 1:
        //     context.goNamed(SpendScreen.path);
        //     break;
        //   case 2:
        //     context.goNamed(ToolsScreen.path);
        //     break;
        //   case 3:
        //     context.goNamed(HiveScreen.path);
        //     break;
        //   case 4:
        //     context.pushNamed(PremiumScreen.path);
        //     break;
        //   default:
        //     break;
        // }
        // switch (index) {
        //   case 0:
        //     context.goNamed(HomeScreen.path);
        //     break;
        //   case 1:
        //     context.goNamed(DashboardScreen.path);
        //     break;
        //   case 2:
        //     context.goNamed(SpendScreen.path);
        //     break;
        //   case 3:
        //     context.goNamed(ToolsScreen.path);
        //     break;
        //   case 4:
        //     context.goNamed(HiveScreen.path);
        //     break;
        //   case 5:
        //     context.pushNamed(PremiumScreen.path);
        //     break;
        //   default:
        //     break;
        // }
      },
      type: BottomNavigationBarType.fixed,
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      ),
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      selectedItemColor: AppColors.black,
      unselectedItemColor: AppColors.grey,
      items: [
        BottomNavigationBarItem(
          activeIcon: AppIcon(AppIcons.homeIcon, size: 20),
          icon: AppIcon(AppIcons.homeIcon, size: 20, color: AppColors.grey),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          activeIcon: AppIcon(AppIcons.budgetIcon, size: 20),
          icon: AppIcon(AppIcons.budgetIcon, size: 20, color: AppColors.grey),
          label: 'Dashboard',
        ),
        // BottomNavigationBarItem(
        //   activeIcon: AppIcon(AppIcons.spendIcon, size: 20),
        //   icon: AppIcon(AppIcons.spendIcon, size: 20, color: AppColors.grey),
        //   label: 'Wallet',
        // ),
        BottomNavigationBarItem(
          activeIcon: AppIcon(AppIcons.toolsIcon, size: 20),
          icon: AppIcon(AppIcons.toolsIcon, size: 20, color: AppColors.grey),
          label: 'Tools',
        ),
        BottomNavigationBarItem(
          activeIcon: AppIcon(AppIcons.hiveIcon, size: 20),
          icon: AppIcon(AppIcons.hiveIcon, size: 20, color: AppColors.grey),
          label: 'Hive',
        ),
        BottomNavigationBarItem(
          activeIcon: AppIcon(AppIcons.crownIcon, size: 20),
          icon: AppIcon(AppIcons.crownIcon, size: 20, color: AppColors.grey),
          label: 'Premium',
        ),
      ],
    );
  }
}
