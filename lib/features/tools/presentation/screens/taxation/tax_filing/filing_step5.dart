import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

class FilingStep5Screen extends StatefulWidget {
  static const String path = FilingRoutes.step5;

  const FilingStep5Screen({super.key});

  @override
  State<FilingStep5Screen> createState() => _FilingStep5ScreenState();
}

class _FilingStep5ScreenState extends State<FilingStep5Screen> {
  // 0 = Tax Pot, 1 = Savvy Bee Wallet, 2 = Bank Transfer
  int _selectedPaymentIndex = 0;

  static const _yellow = Color(0xFFF5C842);

  void _onConfirmPayment() {
    AppNotification.show(
      context,
      message: 'Payment confirmed! ✓ Your return is now ready for submission.',
      icon: Icons.check_circle_outline,
      iconColor: const Color(0xFF43A047),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) context.pushNamed(FilingRoutes.step6);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Tax Payment'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              children: [
                _StepBadge(label: 'STEP 5 OF 6 · TAX PAYMENT'),
                const Gap(16),
                const Text(
                  'Now for your taxes.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 24 * 0.02,
                  ),
                ),
                const Gap(6),
                Text(
                  'Filing fee cleared. Time to settle your 2025 tax liability.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    color: AppColors.greyDark,
                    letterSpacing: 13 * 0.02,
                  ),
                ),
                const Gap(20),

                // ── Dark tax liability card ────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2025 Tax Liability',
                        style: const TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 12,
                          color: Colors.white60,
                          letterSpacing: 12 * 0.02,
                        ),
                      ),
                      const Gap(4),
                      const Text(
                        '₦118,400',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 32 * 0.02,
                        ),
                      ),
                      const Gap(10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 6,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Color(0xFF43A047),
                            ),
                            const Text(
                              'Tax Pot: ₦121,000 — You\'re covered',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF81C784),
                                letterSpacing: 11 * 0.02,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),

                // ── Tax pot info card ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FFF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF43A047).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.savings_outlined,
                          size: 18,
                          color: Color(0xFF43A047),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Tax Pot has ₦121,000 saved.',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 13 * 0.02,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              'You saved exactly for this. Pay directly from your Tax Pot — you\'re fully covered with ₦2,600 to spare.',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 12,
                                color: AppColors.greyDark,
                                letterSpacing: 12 * 0.02,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // ── Breakdown ─────────────────────────────────────────
                const Text(
                  'Breakdown',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 14 * 0.02,
                  ),
                ),
                const Gap(12),
                _BreakdownRow(label: 'Tax payable', value: '₦118,400'),
                _BreakdownRow(label: 'Tax Pot balance', value: '₦121,000'),
                _BreakdownRow(
                  label: 'Remaining after payment',
                  value: '₦2,600',
                  valueColor: const Color(0xFF43A047),
                ),
                const Gap(20),

                // ── Payment method ────────────────────────────────────
                const Text(
                  'Payment method',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 14 * 0.02,
                  ),
                ),
                const Gap(12),

                _PaymentMethodTile(
                  icon: Icons.savings_outlined,
                  title: 'Pay from Tax Pot',
                  subtitle: 'Balance: ₦121,000 — you\'re fully covered',
                  badge: 'Recommended',
                  isSelected: _selectedPaymentIndex == 0,
                  isDisabled: false,
                  onTap: () => setState(() => _selectedPaymentIndex = 0),
                ),
                const Gap(10),
                _PaymentMethodTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Savvy Bee Wallet',
                  subtitle: 'Balance: ₦5,000 — insufficient',
                  isSelected: _selectedPaymentIndex == 1,
                  isDisabled: true,
                  onTap: () {},
                ),
                const Gap(10),
                _PaymentMethodTile(
                  icon: Icons.account_balance_outlined,
                  title: 'Bank Transfer to FIRS',
                  subtitle: 'Account details pre-filled',
                  isSelected: _selectedPaymentIndex == 2,
                  isDisabled: false,
                  onTap: () => setState(() => _selectedPaymentIndex = 2),
                ),
                const Gap(16),

                // ── Coming soon note ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _yellow.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _yellow.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.bolt,
                        size: 16,
                        color: Color(0xFFF5C842),
                      ),
                      Expanded(
                        child: Text(
                          'Coming soon: Savvy Bee will pay your taxes directly on your behalf, automatically on the due date.',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 11,
                            color: AppColors.greyDark,
                            letterSpacing: 11 * 0.02,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
          BottomActionButton(
            label: 'Confirm tax payment — ₦118,400',
            onTap: _onConfirmPayment,
          ),
        ],
      ),
    );
  }
}

// ── Breakdown row ─────────────────────────────────────────────────────────────

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              color: AppColors.greyDark,
              letterSpacing: 13 * 0.02,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
              letterSpacing: 13 * 0.02,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment method tile ───────────────────────────────────────────────────────

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.45 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? _yellow : AppColors.borderLight,
              width: isSelected ? 1.8 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? _yellow.withValues(alpha: 0.05) : Colors.white,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 13 * 0.02,
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _yellow,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                letterSpacing: 9 * 0.02,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 11,
                        color: AppColors.greyDark,
                        letterSpacing: 11 * 0.02,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _yellow : AppColors.grey,
                    width: 2,
                  ),
                  color: isSelected ? _yellow : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 12, color: Colors.black)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step badge ────────────────────────────────────────────────────────────────

class _StepBadge extends StatelessWidget {
  final String label;
  const _StepBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFF5C842),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF5C842),
            letterSpacing: 11 * 0.02,
          ),
        ),
      ],
    );
  }
}
