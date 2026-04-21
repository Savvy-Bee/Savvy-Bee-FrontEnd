import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/back_button_widget.dart';

class SpendNotificationsSettingsScreen extends StatefulWidget {
  const SpendNotificationsSettingsScreen({super.key});

  @override
  State<SpendNotificationsSettingsScreen> createState() => _SpendNotificationsSettingsScreenState();
}

class _SpendNotificationsSettingsScreenState extends State<SpendNotificationsSettingsScreen> {
  bool _pushNotifications = true;
  bool _aiNudges = true;
  bool _transactionAlerts = true;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const BackButtonWidget(),
                const SizedBox(height: 20),

                // Header
                Text('Settings', style: AppTextStyles.displayLarge),
                const SizedBox(height: 2),
                Text('Preferences & privacy', style: AppTextStyles.bodySmall),
                const SizedBox(height: 28),

                // Notifications section
                _SectionLabel(label: 'Notifications'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _ToggleRow(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.foodAmber,
                        iconBg: AppColors.foodAmberLight,
                        label: 'Push Notifications',
                        subtitle: 'All app notifications',
                        value: _pushNotifications,
                        onChanged: (v) =>
                            setState(() => _pushNotifications = v),
                        showDivider: true,
                      ),
                      _ToggleRow(
                        icon: Icons.auto_awesome_rounded,
                        iconColor: AppColors.billsPurple,
                        iconBg: AppColors.billsPurpleLight,
                        label: 'AI Nudges',
                        subtitle: 'Smart spending alerts',
                        value: _aiNudges,
                        onChanged: (v) => setState(() => _aiNudges = v),
                        showDivider: true,
                      ),
                      _ToggleRow(
                        icon: Icons.receipt_long_rounded,
                        iconColor: AppColors.entertainmentGreen,
                        iconBg: AppColors.entertainmentGreenLight,
                        label: 'Transaction Alerts',
                        subtitle: 'Every transaction',
                        value: _transactionAlerts,
                        onChanged: (v) =>
                            setState(() => _transactionAlerts = v),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Privacy & AI section
                _SectionLabel(label: 'Privacy & AI'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _NavRow(
                        icon: Icons.remove_red_eye_outlined,
                        iconColor: AppColors.transportBlue,
                        iconBg: AppColors.transportBlueLight,
                        label: 'Data Usage',
                        subtitle: 'What Nahl learns from you',
                        showDivider: true,
                        onTap: () {},
                      ),
                      _NavRow(
                        icon: Icons.settings_rounded,
                        iconColor: AppColors.billsPurple,
                        iconBg: AppColors.billsPurpleLight,
                        label: 'AI Behavior',
                        subtitle: "Customize Nahl's style",
                        showDivider: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Security section
                _SectionLabel(label: 'Security'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _NavRow(
                        icon: Icons.lock_reset_rounded,
                        iconColor: AppColors.stressRed,
                        iconBg: AppColors.stressRedLight,
                        label: 'Change PIN',
                        subtitle: 'Update your security PIN',
                        showDivider: true,
                        onTap: () {},
                      ),
                      _NavRow(
                        icon: Icons.fingerprint_rounded,
                        iconColor: AppColors.transportBlue,
                        iconBg: AppColors.transportBlueLight,
                        label: 'Biometrics',
                        subtitle: 'Fingerprint & Face ID',
                        showDivider: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: AppColors.foodAmber,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.progressBg,
                thumbColor: WidgetStateProperty.all(Colors.white),
              ),
            ],
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

class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final bool showDivider;
  final VoidCallback? onTap;

  const _NavRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
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
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTextStyles.labelSmall),
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
