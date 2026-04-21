import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/back_button_widget.dart';
import 'accounts_screen.dart';
import 'goals_screen.dart';
import 'settings_screen.dart';

class SpendProfileScreen extends StatelessWidget {
  const SpendProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                const BackButtonWidget(),
                const SizedBox(height: 28),

                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
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
                  'Adebayo Ogunleye',
                  style: AppTextStyles.headingMedium.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'adebayo@example.com',
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
                      Text('₦152,000', style: AppTextStyles.amountLarge),
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
                        subtitle: '2 accounts',
                        showDivider: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountsScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.flag_rounded,
                        iconBg: AppColors.entertainmentGreenLight,
                        iconColor: AppColors.entertainmentGreen,
                        label: 'Goals & Capsules',
                        subtitle: '3 active',
                        showDivider: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_rounded,
                        iconBg: AppColors.coralLight,
                        iconColor: AppColors.coral,
                        label: 'Notifications',
                        subtitle: null,
                        showDivider: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.lock_rounded,
                        iconBg: AppColors.stressRedLight,
                        iconColor: AppColors.stressRed,
                        label: 'Security',
                        subtitle: null,
                        showDivider: false,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                Text(
                  'SavvyBre v1.0.0',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
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
                const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 72, endIndent: 18, color: AppColors.borderLight),
      ],
    );
  }
}