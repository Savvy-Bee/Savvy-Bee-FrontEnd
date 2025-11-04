import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spend_dashboard_screen.dart';

import '../utils/assets/illustrations.dart';
import '../utils/assets/logos.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainWrapper extends ConsumerWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildHeader(context),
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        ref.watch(bottomNavIndexProvider),
        ref,
      ),
    );
  }

  PreferredSize _buildHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.pushNamed(ChatScreen.path),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    Illustrations.dashAvatar,
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
              SvgPicture.asset(Logos.logoSvg, height: 40, width: 40),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
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
        ref.read(bottomNavIndexProvider.notifier).state = index;
        switch (index) {
          case 0:
            context.goNamed(DashboardScreen.path);
            break;
          case 1:
            context.goNamed(SpendScreen.path);
            break;
          case 2:
            context.goNamed('add');
            break;
          case 3:
            context.goNamed('notifications');
            break;
          case 4:
            context.goNamed('messages');
            break;
          case 5:
            context.goNamed('profile');
            break;
          default:
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      fixedColor: AppColors.black,
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
        fontFamily: Constants.neulisNeueFontFamily,
      ),
      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: Constants.neulisNeueFontFamily,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: AppColors.black),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search, color: AppColors.black),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, color: AppColors.black),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications, color: AppColors.black),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message, color: AppColors.black),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: AppColors.black),
          label: 'Profile',
        ),
      ],
    );
  }
}
