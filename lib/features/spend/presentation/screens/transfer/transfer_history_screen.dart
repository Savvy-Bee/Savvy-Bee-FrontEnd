import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/date_time_extension.dart';
import '../../../../../core/utils/num_extensions.dart';
import '../../../../../core/widgets/custom_card.dart';
import '../../../../../core/widgets/custom_input_field.dart';
import '../../providers/wallet_provider.dart';
import '../../../domain/models/wallet.dart';
import '../transactions/transaction_history_screen.dart';

class TransferHistoryScreen extends ConsumerStatefulWidget {
  static const String path = '/transfer-history';

  const TransferHistoryScreen({super.key});

  @override
  ConsumerState<TransferHistoryScreen> createState() =>
      _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends ConsumerState<TransferHistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer History'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextFormField(
              isRounded: true,
              hint: 'Search transactions',
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
            const Gap(16),
            // Expanded(
            //   child: transactionsAsync.when(
            //     data: (apiResponse) {
            //       final all = apiResponse.data?.transactions ?? [];

            //       if (all.isEmpty) {
            //         return _EmptyState(
            //           icon: Icons.swap_horiz_rounded,
            //           message: 'No transfers yet',
            //         );
            //       }

            //       final filtered = _searchQuery.isEmpty
            //           ? all
            //           : all.where((tx) {
            //               return tx.narration
            //                       .toLowerCase()
            //                       .contains(_searchQuery) ||
            //                   tx.transactionFor
            //                       .toLowerCase()
            //                       .contains(_searchQuery);
            //             }).toList();

            //       if (filtered.isEmpty) {
            //         return _EmptyState(
            //           icon: Icons.search_off_rounded,
            //           message: 'No matching transactions',
            //         );
            //       }

            //       final grouped = _groupByDate(filtered);

            //       return RefreshIndicator(
            //         onRefresh: () async =>
            //             ref.read(transactionListProvider.notifier).refresh(),
            //         child: ListView.separated(
            //           itemCount: grouped.length,
            //           separatorBuilder: (_, __) => const Gap(16),
            //           itemBuilder: (_, index) {
            //             final entry = grouped.entries.elementAt(index);
            //             return TransactionHistoryCard(
            //               date: entry.key,
            //               transactions: entry.value,
            //             );
            //           },
            //         ),
            //       );
            //     },
            //     loading: () =>
            //         const Center(child: CircularProgressIndicator()),
            //     error: (error, _) => Center(
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(
            //             Icons.error_outline,
            //             size: 64,
            //             color: AppColors.error,
            //           ),
            //           const Gap(16),
            //           Text(
            //             'Failed to load transactions',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: AppColors.textSecondary,
            //             ),
            //           ),
            //           const Gap(8),
            //           TextButton(
            //             onPressed: () =>
            //                 ref.read(transactionListProvider.notifier).refresh(),
            //             child: const Text('Retry'),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<WalletTransaction>> _groupByDate(
    List<WalletTransaction> transactions,
  ) {
    final Map<DateTime, List<WalletTransaction>> grouped = {};
    for (final tx in transactions) {
      final date = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
      grouped.putIfAbsent(date, () => []).add(tx);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: grouped[k]!};
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.greyDark),
          const Gap(16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
