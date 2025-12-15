import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/date_formatter.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/pay_bills_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/transaction_history_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/transfer_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/add_money_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/create_wallet_screen.dart';

import '../../../../core/utils/assets/illustrations.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../dashboard/presentation/widgets/info_card.dart';

class SpendScreen extends ConsumerStatefulWidget {
  static String path = '/spend';

  const SpendScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SpendScreenState();
}

class _SpendScreenState extends ConsumerState<SpendScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: dashboardAsync.when(
          skipLoadingOnRefresh: false,
          data: (response) {
            if (response.data == null) {
              return _buildEmptyStateWidget();
            }

            final dashboard = response.data!;
            final hasWallet = dashboard.accounts.ngnAccount != null;

            if (!hasWallet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 24,
                children: [
                  _buildEmptyStateWidget(),
                  _buildActionButtonsRow(context, enabled: false),
                  _buildRecentTransactionsCard(hasWallet),
                  // _buildEmptyTransactionsCard(),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardDataProvider);
                ref.invalidate(transactionListProvider);
              },
              child: ListView(
                children: [
                  WalletBalanceCard(dashboard: dashboard),
                  const Gap(24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 24,
                    children: [
                      _buildQuickActionButton(
                        AppIcons.walletIcon,
                        'Pay bills',
                        () => context.pushNamed(PayBillsScreen.path),
                      ),
                      _buildQuickActionButton(
                        AppIcons.sendIcon,
                        'Transfer',
                        () => context.pushNamed(TransferScreen.path),
                      ),
                      _buildQuickActionButton(
                        AppIcons.documentIcon,
                        'Details',
                        () => context.pushNamed(TransactionHistoryScreen.path),
                      ),
                    ],
                  ),
                  const Gap(24.0),
                  _buildRecentTransactionsCard(hasWallet),
                  const Gap(24.0),
                  InfoCard(
                    title: 'Ask Nahl',
                    description:
                        'Get answers to questions on your spending, saving, budgets and cashflow!',
                    avatar: Illustrations.lunaAvatar,
                    borderRadius: 32,
                    onTap: () => context.pushNamed(ChatScreen.path),
                  ),
                ],
              ),
            );
          },
          loading: () => CustomLoadingWidget(),
          error: (error, stack) => CustomErrorWidget.error(
            onRetry: () => ref.invalidate(dashboardDataProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context, {bool enabled = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 24,
      children: [
        _buildQuickActionButton(
          AppIcons.walletIcon,
          'Pay bills',
          enabled ? () => context.pushNamed(PayBillsScreen.path) : null,
        ),
        _buildQuickActionButton(
          AppIcons.sendIcon,
          'Transfer',
          enabled ? () => context.pushNamed(TransferScreen.path) : null,
        ),
        _buildQuickActionButton(
          AppIcons.documentIcon,
          'Details',
          enabled
              ? () => context.pushNamed(TransactionHistoryScreen.path)
              : null,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String icon,
    String label,
    VoidCallback? onPressed,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.outlined(
          onPressed: onPressed,
          icon: AppIcon(
            icon,
            size: 24,
            color: onPressed == null ? AppColors.grey : null,
          ),
          padding: EdgeInsets.all(16),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: onPressed == null ? AppColors.grey : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateWidget() {
    return CustomCard(
      height: 150,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filled(
              onPressed: () => context.pushNamed(CreateWalletScreen.path),
              icon: Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
              ),
            ),
            const Gap(24.0),
            Text(
              'Create your Savvy Wallet Account to start spending',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsCard(bool hasWallet) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                InkWell(
                  onTap: hasWallet
                      ? () => context.pushNamed(TransactionHistoryScreen.path)
                      : null,
                  child: Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: Constants.neulisNeueFontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const Gap(16),

          ...transactionsAsync.when(
            data: (response) {
              final transactions = response.data?.transactions ?? [];

              if (!hasWallet) {
                return [
                  CustomErrorWidget(
                    subtitle:
                        'Create your Savvy Wallet Account to start spending and view transactions',
                    isActionButtonFilled: true,
                    actionButtonText: 'Create account',
                    onActionPressed: () {
                      context.pushNamed(CreateWalletScreen.path);
                    },
                  ),
                  const Gap(16),
                ];
              }
              if (transactions.isEmpty) {
                return [CustomErrorWidget(subtitle: 'No recent transaction')];
              }

              return transactions
                  .take(4)
                  .map(
                    (transaction) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                transaction.type.name == 'credit'
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: transaction.type.name == 'credit'
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              const Gap(16.0),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.narration,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          Constants.neulisNeueFontFamily,
                                    ),
                                  ),
                                  Text(
                                    '${DateFormatter.formatRelative(transaction.createdAt)} ${DateFormatter.formatTime(transaction.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textLight,
                                      fontFamily:
                                          Constants.neulisNeueFontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            transaction.type.name == 'credit'
                                ? transaction.amount.formatCurrency()
                                : transaction.amount.formatCurrency(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: Constants.neulisNeueFontFamily,
                              color: transaction.type.name == 'credit'
                                  ? AppColors.success
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
            },
            error: (error, stackTrace) => [CustomErrorWidget.error()],
            loading: () => [CustomLoadingWidget()],
          ),
        ],
      ),
    );
  }
}

class WalletBalanceCard extends ConsumerWidget {
  final WalletDashboardData dashboard;

  const WalletBalanceCard({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryAccount = dashboard.accounts;

    return CustomCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'SAVVY WALLET - ${primaryAccount.ngnAccount?.accountNumber}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(8),
                  InkWell(
                    onTap: () {
                      // Copy account number to clipboard
                    },
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      weight: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () =>
                    _OptionsBottomSheet.showOptionsBottomSheet(context, ref),
                style: Constants.collapsedButtonStyle,
                icon: Icon(Icons.more_vert, color: AppColors.greyDark),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                primaryAccount.balance.toString(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Last updated ${DateFormatter.formatRelative(DateTime.now())}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.pushNamed(AddMoneyScreen.path);
                },
                style: Constants.collapsedButtonStyle.copyWith(
                  backgroundColor: WidgetStateProperty.all(AppColors.black),
                ),
                icon: Icon(Icons.add, color: AppColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionsBottomSheet extends StatelessWidget {
  final WidgetRef ref;

  const _OptionsBottomSheet({required this.ref});

  static void showOptionsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _OptionsBottomSheet(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OPTIONS',
                style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
                constraints: BoxConstraints(),
                style: Constants.collapsedButtonStyle,
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildOptionsTile(
                title: 'Refresh',
                icon: Icons.refresh,
                onTap: () {
                  ref.invalidate(dashboardDataProvider);
                  ref.invalidate(transactionListProvider);
                  context.pop();
                },
              ),
              _buildOptionsTile(
                title: 'Turn on privacy',
                icon: Icons.visibility_off,
                onTap: () {
                  // TODO: Implement privacy toggle
                  context.pop();
                },
              ),
              _buildOptionsTile(
                title: 'Manage accounts',
                icon: Icons.account_balance,
                onTap: () {
                  // TODO: Navigate to manage accounts screen
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16)),
      leading: Icon(icon, size: 20),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 5,
      minVerticalPadding: 0,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
    );
  }
}
