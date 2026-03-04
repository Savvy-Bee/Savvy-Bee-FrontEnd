import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

class FilingStep4Screen extends StatefulWidget {
  static const String path = FilingRoutes.step4;

  const FilingStep4Screen({super.key});

  @override
  State<FilingStep4Screen> createState() => _FilingStep4ScreenState();
}

class _FilingStep4ScreenState extends State<FilingStep4Screen> {
  int _selectedPaymentIndex = 0; // 0 = Savvy Bee Wallet, 1 = Debit Card

  static const _yellow = Color(0xFFF5C842);

  void _onPayFee() {
    AppNotification.show(
      context,
      message:
          'Filing fee received! 🎉 Your partner is now assigned to your return.',
      icon: Icons.celebration_outlined,
      iconColor: _yellow,
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) context.pushNamed(FilingRoutes.step5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Filing Fee'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              children: [
                _StepBadge(label: 'STEP 4 OF 6 · FILING FEE'),
                const Gap(16),
                const Text(
                  'Two payments, clearly shown.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 24 * 0.02,
                  ),
                ),
                const Gap(8),
                Text(
                  'There are two payments here — one to file, one to pay your taxes. Let\'s start with the filing fee so your partner can get to work.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    color: AppColors.greyDark,
                    letterSpacing: 13 * 0.02,
                  ),
                ),
                const Gap(20),

                // ── Two payment cards side by side ────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _PaymentTypeCard(
                        label: 'FILING FEE',
                        amount: '₦25,000',
                        subtitle: 'Savvy Bee service',
                        isActive: true,
                        actionLabel: 'Pay first',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PaymentTypeCard(
                        label: 'TAX LIABILITY',
                        amount: '₦118,400',
                        subtitle: 'Paid to FIRS',
                        isActive: false,
                        actionLabel: 'Next step',
                      ),
                    ),
                  ],
                ),
                const Gap(20),

                // ── Wallet status ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Savvy Bee Wallet',
                          style: const TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 13 * 0.02,
                          ),
                        ),
                      ),
                      Text(
                        '₦25,000',
                        style: const TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 13 * 0.02,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          '✓ Sufficient',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF43A047),
                            letterSpacing: 10 * 0.02,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // ── Payment method label ──────────────────────────────
                Text(
                  'Choose payment method for filing fee:',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    color: AppColors.greyDark,
                    letterSpacing: 13 * 0.02,
                  ),
                ),
                const Gap(12),

                // ── Payment method options ────────────────────────────
                _PaymentMethodTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Savvy Bee Wallet',
                  subtitle: 'Balance: ₦25,000',
                  isSelected: _selectedPaymentIndex == 0,
                  onTap: () => setState(() => _selectedPaymentIndex = 0),
                ),
                const Gap(10),
                _PaymentMethodTile(
                  icon: Icons.credit_card,
                  title: 'Debit/Credit Card',
                  subtitle: 'Visa •••• 4521',
                  isSelected: _selectedPaymentIndex == 1,
                  onTap: () => setState(() => _selectedPaymentIndex = 1),
                ),
                const Gap(20),

                // ── Fee summary ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _FeeRow(
                        label: 'Filing fee (Freelancer tier)',
                        value: '₦25,000',
                      ),
                      const Gap(8),
                      _FeeRow(
                        label: 'Processing fee',
                        value: 'Free',
                        valueColor: const Color(0xFF43A047),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: AppColors.borderLight),
                      ),
                      _FeeRow(
                        label: 'Total today',
                        value: '₦25,000',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Text(
                  'Your tax liability of ₦118,400 will be paid in the next step',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 11,
                    color: AppColors.greyDark,
                    letterSpacing: 11 * 0.02,
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
          BottomActionButton(
            label: 'Pay filing fee — ₦25,000',
            onTap: _onPayFee,
          ),
        ],
      ),
    );
  }
}

// ── Payment type comparison card ─────────────────────────────────────────────

class _PaymentTypeCard extends StatelessWidget {
  final String label;
  final String amount;
  final String subtitle;
  final bool isActive;
  final String actionLabel;

  const _PaymentTypeCard({
    required this.label,
    required this.amount,
    required this.subtitle,
    required this.isActive,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? Color(0xFFF5C842) : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? Color(0xFFF5C842) : AppColors.greyDark,
              letterSpacing: 10 * 0.02,
            ),
          ),
          const Gap(4),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : Colors.black87,
              letterSpacing: 20 * 0.02,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 11,
              color: isActive ? Colors.white60 : AppColors.greyDark,
              letterSpacing: 11 * 0.02,
            ),
          ),
          const Gap(10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF5C842).withOpacity(0.3) : Color(0xFF8eaaff).withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              actionLabel,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Color(0xFFF5C842) : Color(0xFF8eaaff),
                letterSpacing: 11 * 0.02,
              ),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 13 * 0.02,
                    ),
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
    );
  }
}

// ── Fee row ───────────────────────────────────────────────────────────────────

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _FeeRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 13 * 0.02,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: valueColor ?? Colors.black87,
            letterSpacing: 13 * 0.02,
          ),
        ),
      ],
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
            color: Colors.black,
            letterSpacing: 11 * 0.02,
          ),
        ),
      ],
    );
  }
}
