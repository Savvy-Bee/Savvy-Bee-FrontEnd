import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/back_button_widget.dart';

class SpendAccountsScreen extends StatelessWidget {
  const SpendAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                      Text('Accounts', style: AppTextStyles.displayLarge),
                      const SizedBox(height: 2),
                      Text('Connected banks', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 24),

                      // Total across accounts
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
                            Text(
                              'Total Across Accounts',
                              style: AppTextStyles.labelMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('₦152,000', style: AppTextStyles.amountLarge),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Access Bank card
                      _BankCard(
                        bankName: 'Access Bank',
                        isPrimary: true,
                        accountNumber: '8123456789',
                        balance: '₦120,000',
                        iconColor: AppColors.stressRed,
                        iconBg: AppColors.stressRedLight,
                        icon: Icons.account_balance_rounded,
                      ),
                      const SizedBox(height: 12),

                      // GTBank card
                      _BankCard(
                        bankName: 'GTBank',
                        isPrimary: false,
                        accountNumber: '9876543218',
                        balance: '₦32,000',
                        iconColor: AppColors.foodAmber,
                        iconBg: AppColors.foodAmberLight,
                        icon: Icons.account_balance_rounded,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Connect New Account CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: _PrimaryButton(
                label: '+ Connect New Account',
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  final String bankName;
  final bool isPrimary;
  final String accountNumber;
  final String balance;
  final Color iconColor;
  final Color iconBg;
  final IconData icon;

  const _BankCard({
    required this.bankName,
    required this.isPrimary,
    required this.accountNumber,
    required this.balance,
    required this.iconColor,
    required this.iconBg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(bankName, style: AppTextStyles.amountSmall),
                        if (isPrimary) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.foodAmberLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Primary',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.foodAmber,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(accountNumber, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.entertainmentGreenLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.entertainmentGreen,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),
          Text('Available Balance', style: AppTextStyles.labelSmall),
          const SizedBox(height: 5),
          Text(
            balance,
            style: AppTextStyles.amountLarge.copyWith(fontSize: 24),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PrimaryButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.foodAmber,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
