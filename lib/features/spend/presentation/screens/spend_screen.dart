import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/date_time_extension.dart';
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
import '../../../home/presentation/providers/home_data_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class SpendScreen extends ConsumerStatefulWidget {
  static const String path = '/spend';

  const SpendScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SpendScreenState();
}

class _SpendScreenState extends ConsumerState<SpendScreen> {
  AppBar _buildAppBar(BuildContext context) {
    final firstName =
        ref.watch(homeDataProvider).valueOrNull?.data?.firstName ?? '';

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => context.pushNamed(ChatScreen.path),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/topbar/nav-left-icon.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Chat with Nahl',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/topbar/nav-center-icon.png',
            width: 30,
            height: 32,
            fit: BoxFit.contain,
          ),
          GestureDetector(
            onTap: () => context.pushNamed(ProfileScreen.path),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Text(
                  firstName.isNotEmpty
                      ? firstName
                            .substring(0, firstName.length > 1 ? 2 : 1)
                            .toUpperCase()
                      : 'Me',
                  style: const TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
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
                ref.invalidate(spendDashboardDataProvider);
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
            onRetry: () => ref.invalidate(spendDashboardDataProvider),
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
                Text('RECENT TRANSACTIONS', style: TextStyle(fontSize: 10)),
                InkWell(
                  onTap: hasWallet
                      ? () => context.pushNamed(TransactionHistoryScreen.path)
                      : null,
                  child: Text(
                    'VIEW ALL',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
                        children: [
                          // Direction icon
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: transaction.isCredit
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              transaction.isCredit
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              size: 16,
                              color: transaction.isCredit
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          const Gap(12.0),
                          // Narration + timestamp
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.narration.isNotEmpty
                                      ? transaction.narration
                                      : transaction.transactionFor,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Gap(2),
                                Row(
                                  children: [
                                    Text(
                                      '${transaction.createdAt.formatRelative()} · ${transaction.createdAt.formatTime()}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                    if (!transaction.isSuccess) ...[
                                      const Gap(6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: transaction.isPending
                                              ? Colors.orange.withOpacity(0.15)
                                              : AppColors.error.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          transaction.status.value,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: transaction.isPending
                                                ? Colors.orange
                                                : AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Gap(8),
                          // Amount
                          Text(
                            '${transaction.isCredit ? '+' : '-'}${transaction.amount.formatCurrency()}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: transaction.isCredit
                                  ? AppColors.success
                                  : AppColors.error,
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
                    style: TextStyle(fontSize: 10, color: AppColors.textLight),
                  ),
                  const Gap(8),
                  InkWell(
                    onTap: () {
                      final acctNo = primaryAccount.ngnAccount?.accountNumber ?? '';
                      if (acctNo.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: acctNo));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account number copied'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
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
              Consumer(
                builder: (context, ref, _) {
                  final isPrivate = ref.watch(balancePrivacyProvider);
                  return Text(
                    isPrivate ? '₦ ••••••' : primaryAccount.balance.formatCurrency(),
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Last updated ${DateTime.now().formatRelative()}',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
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
      useRootNavigator: true,
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
              Text('OPTIONS'),
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
                  ref.invalidate(spendDashboardDataProvider);
                  ref.invalidate(transactionListProvider);
                  context.pop();
                },
              ),
              Consumer(
                builder: (context, ref, _) {
                  final isPrivate = ref.watch(balancePrivacyProvider);
                  return _buildOptionsTile(
                    title: isPrivate ? 'Turn off privacy' : 'Turn on privacy',
                    icon: isPrivate ? Icons.visibility : Icons.visibility_off,
                    onTap: () {
                      ref.read(balancePrivacyProvider.notifier).state = !isPrivate;
                      context.pop();
                    },
                  );
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
