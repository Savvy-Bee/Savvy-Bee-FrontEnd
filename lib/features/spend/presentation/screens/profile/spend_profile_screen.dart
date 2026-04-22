import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/profile/spend_account_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/profile/spend_goals_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/profile/spend_notifications_settings_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/back_button_widget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';

class SpendProfileScreen extends ConsumerWidget {
  static const String path = '/spend/profile';

  const SpendProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final dashboardAsync = ref.watch(spendDashboardDataProvider);
    final linkedAccountsAsync = ref.watch(linkedAccountsProvider);
    final goalsAsync = ref.watch(savingsGoalsProvider);

    final fullName = homeDataAsync.maybeWhen(
      data: (response) =>
          '${response.data.firstName} ${response.data.lastName}'.trim(),
      orElse: () => null,
    );
    final email = ref.watch(currentUserProvider)?.email ?? '';

    final walletBalance = dashboardAsync.maybeWhen(
      data: (response) => response.data?.accounts.balance,
      orElse: () => null,
    );

    final connectedAccountsCount = linkedAccountsAsync.maybeWhen(
      data: (accounts) => accounts.length,
      orElse: () => null,
    );

    final activeGoalsCount = goalsAsync.maybeWhen(
      data: (goals) => goals.where((g) => !g.isCompleted).length,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const BackButtonWidget(),
                ),
                const SizedBox(height: 28),

                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.foodAmber,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  (fullName == null || fullName.isEmpty) ? '—' : fullName,
                  style: AppTextStyles.headingMedium.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? '—' : email,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 28),

                // Total Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Balance', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 8),
                      Text(
                        walletBalance != null
                            ? walletBalance.formatCurrency(decimalDigits: 0)
                            : '—',
                        style: AppTextStyles.amountLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Menu items
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: Icons.account_balance_rounded,
                        iconBg: AppColors.transportBlueLight,
                        iconColor: AppColors.transportBlue,
                        label: 'Connected Accounts',
                        subtitle: connectedAccountsCount != null
                            ? '$connectedAccountsCount ${connectedAccountsCount == 1 ? 'account' : 'accounts'}'
                            : null,
                        showDivider: true,
                        onTap: () => context.push(SpendAccountsScreen.path),
                      ),
                      _MenuItem(
                        icon: Icons.flag_rounded,
                        iconBg: AppColors.entertainmentGreenLight,
                        iconColor: AppColors.entertainmentGreen,
                        label: 'Goals & Capsules',
                        subtitle: activeGoalsCount != null
                            ? '$activeGoalsCount active'
                            : null,
                        showDivider: true,
                        onTap: () => context.push(SpendGoalsScreen.path),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_rounded,
                        iconBg: AppColors.coralLight,
                        iconColor: AppColors.coral,
                        label: 'Notifications',
                        subtitle: null,
                        showDivider: true,
                        onTap: () =>
                            context.push(SpendNotificationsSettingsScreen.path),
                      ),
                      _MenuItem(
                        icon: Icons.lock_rounded,
                        iconBg: AppColors.stressRedLight,
                        iconColor: AppColors.stressRed,
                        label: 'Security',
                        subtitle: null,
                        showDivider: false,
                        onTap: () =>
                            context.push(SpendNotificationsSettingsScreen.path),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                Text(
                  'SavvyBee v1.0.0',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final bool showDivider;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.showDivider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(showDivider ? 0 : 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTextStyles.amountSmall),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: AppTextStyles.labelSmall),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 18,
            color: AppColors.borderLight,
          ),
      ],
    );
  }
}
