import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/utils/string_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/account_statement_screen.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../providers/wallet_provider.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  static String path = '/transaction-history';

  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    isRounded: true,
                    hint: 'Search',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                const Gap(16),
                InkWell(
                  onTap: () => context.pushNamed(AccountStatementScreen.path),
                  child: Icon(
                    Icons.file_copy_outlined,
                    color: AppColors.greyDark,
                  ),
                ),
              ],
            ),
            const Gap(16),
            Expanded(
              child: transactionsAsync.when(
                data: (transactionsResponse) {
                  final transactions =
                      transactionsResponse.data?.transactions ?? [];

                  if (transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: AppColors.greyDark,
                          ),
                          const Gap(16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              fontFamily: Constants.neulisNeueFontFamily,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter transactions based on search query
                  final filteredTransactions = _searchQuery.isEmpty
                      ? transactions
                      : transactions.where((transaction) {
                          return transaction.narration.toLowerCase().contains(
                                _searchQuery,
                              ) ||
                              transaction.transactionFor.toLowerCase().contains(
                                _searchQuery,
                              );
                        }).toList();

                  if (filteredTransactions.isEmpty) {
                    return Center(
                      child: Text(
                        'No matching transactions',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontFamily: Constants.neulisNeueFontFamily,
                        ),
                      ),
                    );
                  }

                  // Group transactions by date
                  final groupedTransactions = _groupTransactionsByDate(
                    filteredTransactions,
                  );

                  return ListView.separated(
                    itemCount: groupedTransactions.length,
                    separatorBuilder: (context, index) => const Gap(16),
                    itemBuilder: (context, index) {
                      final dateEntry = groupedTransactions.entries.elementAt(
                        index,
                      );
                      return TransactionHistoryCard(
                        date: dateEntry.key,
                        transactions: dateEntry.value,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const Gap(16),
                      Text(
                        'Failed to load transactions',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontFamily: Constants.neulisNeueFontFamily,
                        ),
                      ),
                      const Gap(8),
                      TextButton(
                        onPressed: () {
                          ref.invalidate(transactionListProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Groups transactions by date
  Map<DateTime, List<WalletTransaction>> _groupTransactionsByDate(
    List<WalletTransaction> transactions,
  ) {
    final Map<DateTime, List<WalletTransaction>> grouped = {};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.createdAt.year,
        transaction.createdAt.month,
        transaction.createdAt.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }

    // Sort by date descending
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var key in sortedKeys) key: grouped[key]!};
  }
}

class TransactionHistoryCard extends StatelessWidget {
  final DateTime date;
  final List<WalletTransaction> transactions;

  const TransactionHistoryCard({
    super.key,
    required this.date,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date.formatShortDate(),
          style: TextStyle(
            fontSize: 12,
            fontFamily: Constants.neulisNeueFontFamily,
          ),
        ),
        const Gap(8),
        CustomCard(
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: transactions.map((transaction) {
              return _buildTransactionItem(transaction);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(WalletTransaction transaction) {
    // Determine title based on transaction type and purpose
    String title = transaction.narration;

    // Truncate long titles
    if (title.length > 25) {
      title = '${title.truncate(22)}...';
    }

    // Format time
    final time = transaction.createdAt.formatTime();

    // Format amount with sign based on transaction type
    final amountPrefix = transaction.isCredit ? '+' : '-';
    final amount =
        '$amountPrefix${transaction.amount.formatCurrency(decimalDigits: 0)}';

    // Determine icon and color based on transaction type and status
    Color amountColor = transaction.isCredit
        ? AppColors.success
        : AppColors.error;

    if (transaction.isPending) {
      amountColor = AppColors.textSecondary;
    } else if (transaction.isFailed) {
      amountColor = AppColors.error;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(Assets.coinStackSvg),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: Constants.neulisNeueFontFamily,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (!transaction.isSuccess) ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: transaction.isPending
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              transaction.status.value,
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: Constants.neulisNeueFontFamily,
                                color: transaction.isPending
                                    ? Colors.orange
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: Constants.neulisNeueFontFamily,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
