import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/date_time_extension.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/account_statement_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/transaction_details_screen.dart';
import '../../providers/wallet_provider.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  static const String path = '/transaction-history';

  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'GeneralSans',
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_copy_outlined, color: Colors.black),
            onPressed: () => context.pushNamed(AccountStatementScreen.path),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search notifications',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9E9E9E)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const Gap(24),

            // Notifications List
            Expanded(
              child: transactionsAsync.when(
                data: (transactionsResponse) {
                  var transactions = transactionsResponse.data?.transactions ?? [];

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    transactions = transactions.where((t) {
                      final text = (t.narration + t.transactionFor).toLowerCase();
                      return text.contains(_searchQuery);
                    }).toList();
                  }

                  if (transactions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  final grouped = _groupTransactionsByDate(transactions);

                  return ListView.separated(
                    itemCount: grouped.length,
                    separatorBuilder: (_, __) => const Gap(16),
                    itemBuilder: (context, index) {
                      final entry = grouped.entries.elementAt(index);
                      return _buildNotificationGroup(
                        date: entry.key,
                        transactions: entry.value,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const Gap(16),
                      const Text('Failed to load notifications'),
                      TextButton(
                        onPressed: () => ref.invalidate(transactionListProvider),
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

  Map<DateTime, List<WalletTransaction>> _groupTransactionsByDate(
      List<WalletTransaction> transactions) {
    final Map<DateTime, List<WalletTransaction>> grouped = {};

    for (final t in transactions) {
      final date = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      grouped.putIfAbsent(date, () => []).add(t);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  Widget _buildNotificationGroup({
    required DateTime date,
    required List<WalletTransaction> transactions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date.formatRelative() == 'Today' ? 'Today' : date.formatShortDate(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF757575),
          ),
        ),
        const Gap(12),
        ...transactions.map((tx) => _buildNotificationCard(tx)).toList(),
      ],
    );
  }

  // Notification Card using REAL transaction data + clickable to detail screen
  Widget _buildNotificationCard(WalletTransaction transaction) {
    final isCredit = transaction.isCredit;
    final amountText = '${isCredit ? '+' : '-'}${transaction.amount.formatCurrency(decimalDigits: 0)}';

    final title = transaction.narration.isNotEmpty
        ? transaction.narration
        : transaction.transactionFor;

    return GestureDetector(
      onTap: () => context.pushNamed(
        TransactionDetailScreen.path,
        extra: transaction,
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1), // Soft yellow like screenshot
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                size: 24,
              ),
            ),
            const Gap(14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(6),
                  Text(
                    amountText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCredit ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                    ),
                  ),
                  const Gap(10),
                  Text(
                    '${transaction.createdAt.formatRelative()} ago',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                ],
              ),
            ),

            // More options icon
            const Icon(Icons.more_horiz, color: Color(0xFF9E9E9E), size: 20),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/utils/string_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/account_statement_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/transaction_details_screen.dart';

// import '../../../../../core/utils/date_time_extension.dart';
// import '../../providers/wallet_provider.dart';

// class TransactionHistoryScreen extends ConsumerStatefulWidget {
//   static const String path = '/transaction-history';

//   const TransactionHistoryScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _TransactionHistoryScreenState();
// }

// class _TransactionHistoryScreenState
//     extends ConsumerState<TransactionHistoryScreen> {
//   String _searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     final transactionsAsync = ref.watch(transactionListProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Transaction History')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: CustomTextFormField(
//                     isRounded: true,
//                     hint: 'Search',
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value.toLowerCase();
//                       });
//                     },
//                     prefixIcon: const Padding(
//                       padding: EdgeInsets.only(left: 8.0),
//                       child: Icon(Icons.search, size: 20),
//                     ),
//                   ),
//                 ),
//                 const Gap(16),
//                 InkWell(
//                   onTap: () => context.pushNamed(AccountStatementScreen.path),
//                   child: Icon(
//                     Icons.file_copy_outlined,
//                     color: AppColors.greyDark,
//                   ),
//                 ),
//               ],
//             ),
//             const Gap(16),
//             Expanded(
//               child: transactionsAsync.when(
//                 data: (transactionsResponse) {
//                   final transactions =
//                       transactionsResponse.data?.transactions ?? [];

//                   if (transactions.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.receipt_long_outlined,
//                             size: 64,
//                             color: AppColors.greyDark,
//                           ),
//                           const Gap(16),
//                           Text(
//                             'No transactions yet',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   // Filter transactions based on search query
//                   final filteredTransactions = _searchQuery.isEmpty
//                       ? transactions
//                       : transactions.where((transaction) {
//                           return transaction.narration.toLowerCase().contains(
//                                 _searchQuery,
//                               ) ||
//                               transaction.transactionFor.toLowerCase().contains(
//                                 _searchQuery,
//                               );
//                         }).toList();

//                   if (filteredTransactions.isEmpty) {
//                     return Center(
//                       child: Text(
//                         'No matching transactions',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     );
//                   }

//                   // Group transactions by date
//                   final groupedTransactions = _groupTransactionsByDate(
//                     filteredTransactions,
//                   );

//                   return ListView.separated(
//                     itemCount: groupedTransactions.length,
//                     separatorBuilder: (context, index) => const Gap(16),
//                     itemBuilder: (context, index) {
//                       final dateEntry = groupedTransactions.entries.elementAt(
//                         index,
//                       );
//                       return TransactionHistoryCard(
//                         date: dateEntry.key,
//                         transactions: dateEntry.value,
//                       );
//                     },
//                   );
//                 },
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (error, stack) => Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 64,
//                         color: AppColors.error,
//                       ),
//                       const Gap(16),
//                       Text(
//                         'Failed to load transactions',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                       const Gap(8),
//                       TextButton(
//                         onPressed: () {
//                           ref.invalidate(transactionListProvider);
//                         },
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Groups transactions by date
//   Map<DateTime, List<WalletTransaction>> _groupTransactionsByDate(
//     List<WalletTransaction> transactions,
//   ) {
//     final Map<DateTime, List<WalletTransaction>> grouped = {};

//     for (final transaction in transactions) {
//       final date = DateTime(
//         transaction.createdAt.year,
//         transaction.createdAt.month,
//         transaction.createdAt.day,
//       );

//       if (!grouped.containsKey(date)) {
//         grouped[date] = [];
//       }
//       grouped[date]!.add(transaction);
//     }

//     // Sort by date descending
//     final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
//     return {for (var key in sortedKeys) key: grouped[key]!};
//   }
// }

// class TransactionHistoryCard extends StatelessWidget {
//   final DateTime date;
//   final List<WalletTransaction> transactions;

//   const TransactionHistoryCard({
//     super.key,
//     required this.date,
//     required this.transactions,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(date.formatShortDate(), style: TextStyle(fontSize: 12)),
//         const Gap(8),
//         CustomCard(
//           child: Column(
//             spacing: 16,
//             mainAxisSize: MainAxisSize.min,
//             children: transactions.map((transaction) {
//               return _buildTransactionItem(context, transaction);
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTransactionItem(BuildContext context, WalletTransaction transaction) {
//     // Determine title based on transaction type and purpose
//     String title = transaction.narration;

//     // Truncate long titles
//     if (title.length > 25) {
//       title = '${title.truncate(22)}...';
//     }

//     // Format time
//     final time = transaction.createdAt.formatTime();

//     // Format amount with sign based on transaction type
//     final amountPrefix = transaction.isCredit ? '+' : '-';
//     final amount =
//         '$amountPrefix${transaction.amount.formatCurrency(decimalDigits: 0)}';

//     // Determine icon and color based on transaction type and status
//     Color amountColor = transaction.isCredit
//         ? AppColors.success
//         : AppColors.error;

//     if (transaction.isPending) {
//       amountColor = AppColors.textSecondary;
//     } else if (transaction.isFailed) {
//       amountColor = AppColors.error;
//     }

//     return GestureDetector(
//       onTap: () => context.pushNamed(
//         TransactionDetailScreen.path,
//         extra: transaction,
//       ),
//       behavior: HitTestBehavior.opaque,
//       child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: transaction.isCredit
//                       ? const Color(0xFFE8F5E9)
//                       : const Color(0xFFFFEBEE),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   transaction.isCredit
//                       ? Icons.arrow_downward
//                       : Icons.arrow_upward,
//                   size: 20,
//                   color: transaction.isCredit
//                       ? const Color(0xFF4CAF50)
//                       : const Color(0xFFEF5350),
//                 ),
//               ),
//               const Gap(8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(fontWeight: FontWeight.w500),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Row(
//                       children: [
//                         Text(
//                           time,
//                           style: TextStyle(
//                             fontSize: 8,

//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                         if (!transaction.isSuccess) ...[
//                           const Gap(8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: transaction.isPending
//                                   ? Colors.orange.withValues(alpha: 0.1)
//                                   : Colors.red.withValues(alpha: 0.1),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               transaction.status.value,
//                               style: TextStyle(
//                                 fontSize: 8,

//                                 color: transaction.isPending
//                                     ? Colors.orange
//                                     : Colors.red,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const Gap(8),
//         Text(
//           amount,
//           style: TextStyle(fontWeight: FontWeight.w500, color: amountColor),
//         ),
//       ],
//     ),
//     );
//   }
// }
