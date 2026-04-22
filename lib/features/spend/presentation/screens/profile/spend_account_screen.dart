import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/linked_account.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/back_button_widget.dart';

const _bankColorPalette = [
  (bg: AppColors.stressRedLight, icon: AppColors.stressRed),
  (bg: AppColors.foodAmberLight, icon: AppColors.foodAmber),
  (bg: AppColors.transportBlueLight, icon: AppColors.transportBlue),
  (bg: AppColors.entertainmentGreenLight, icon: AppColors.entertainmentGreen),
  (bg: AppColors.billsPurpleLight, icon: AppColors.billsPurple),
  (bg: AppColors.coralLight, icon: AppColors.coral),
];

class SpendAccountsScreen extends ConsumerWidget {
  static const String path = '/spend/profile/accounts';

  const SpendAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(linkedAccountsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: accountsAsync.when(
          loading: () => const CustomLoadingWidget(),
          error: (e, _) => CustomErrorWidget.error(
            subtitle: e.toString(),
            onRetry: () => ref.invalidate(linkedAccountsProvider),
          ),
          data: (accounts) {
            final total = accounts.fold<double>(
              0,
              (sum, a) => sum + a.balance.available,
            );

            return Column(
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
                                Text(
                                  total.formatCurrency(decimalDigits: 0),
                                  style: AppTextStyles.amountLarge,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (accounts.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No connected accounts yet.',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            )
                          else
                            ...accounts.asMap().entries.map((entry) {
                              final i = entry.key;
                              final account = entry.value;
                              final colors =
                                  _bankColorPalette[i % _bankColorPalette.length];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _BankCard(
                                  account: account,
                                  isPrimary: i == 0,
                                  iconBg: colors.bg,
                                  iconColor: colors.icon,
                                ),
                              );
                            }),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: _PrimaryButton(
                    label: '+ Connect New Account',
                    onTap: () {},
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  final LinkedAccount account;
  final bool isPrimary;
  final Color iconBg;
  final Color iconColor;

  const _BankCard({
    required this.account,
    required this.isPrimary,
    required this.iconBg,
    required this.iconColor,
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
                child: Icon(
                  Icons.account_balance_rounded,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          account.institution.name,
                          style: AppTextStyles.amountSmall,
                        ),
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
                    Text(
                      account.details.accountNumber,
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.entertainmentGreenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
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
            account.balance.available.formatCurrency(decimalDigits: 0),
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
