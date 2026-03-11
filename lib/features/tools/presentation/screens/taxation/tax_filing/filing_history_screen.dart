// lib/features/tools/presentation/screens/taxation/filing/filing_history_screen.dart
//
// Entry point for filing history — replaces FilingRecordScreen as the
// post-flow landing. Lists all past/active filings; tapping opens details.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_history_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_history_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

class FilingHistoryScreen extends ConsumerWidget {
  /// Reuses the existing filingRecord route constant so nothing else breaks.
  static const String path = FilingRoutes.filingRecord;

  const FilingHistoryScreen({super.key});

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(filingHistoryProvider);

    return Scaffold(
      body: Column(
        children: [
          // ── Header (matches FilingRecordScreen style) ──────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 16,
              20,
              20,
            ),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 6,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _yellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Text(
                            'YOUR TAX FILINGS',
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _yellow,
                              letterSpacing: 11 * 0.02,
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      const Text(
                        'Filing History',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 26 * 0.02,
                          height: 1.2,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'All your past and in-progress tax returns.',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 13,
                          color: AppColors.greyDark,
                          letterSpacing: 13 * 0.02,
                        ),
                      ),
                    ],
                  ),
                ),
                // Refresh button
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Refresh',
                  onPressed: () =>
                      ref.read(filingHistoryProvider.notifier).refresh(),
                ),
              ],
            ),
          ),

          // ── List body ──────────────────────────────────────────────
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                message: e.toString().replaceFirst('Exception: ', ''),
                onRetry: () =>
                    ref.read(filingHistoryProvider.notifier).refresh(),
              ),
              data: (items) {
                if (items.isEmpty) return const _EmptyView();
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(filingHistoryProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, i) => _HistoryCard(
                      item: items[i],
                      onTap: () => context.pushNamed(
                        FilingRoutes.filingDetails,
                        pathParameters: {'id': items[i].id},
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Bottom button ──────────────────────────────────────────
          BottomActionButton(
            label: 'Back to home',
            leadingIcon: Icons.home_outlined,
            onTap: () {
              while (context.canPop()) context.pop();
            },
          ),
        ],
      ),
    );
  }
}

// ── History card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final FilingHistoryItem item;
  final VoidCallback onTap;

  const _HistoryCard({required this.item, required this.onTap});

  static const _yellow = Color(0xFFF5C842);
  static final _dateFmt = DateFormat('d MMM y');

  Color _statusColor(FillingStatus s) {
    switch (s) {
      case FillingStatus.completed:
        return const Color(0xFF43A047);
      case FillingStatus.validatingTax:
        return const Color(0xFF1565C0);
      case FillingStatus.rejected:
      case FillingStatus.failed:
        return Colors.redAccent;
      case FillingStatus.pendingPayment:
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF5C6BC0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year + status badge
            Row(
              children: [
                Row(
                  spacing: 6,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      '${item.year} Return',
                      style: const TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 15 * 0.02,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _StatusBadge(
                  label: item.status.displayLabel,
                  color: statusColor,
                ),
              ],
            ),
            const Gap(10),

            // Plan + classification chips
            Wrap(
              spacing: 6,
              children: [
                _MetaChip(label: item.plan),
                if (item.classification != null)
                  _MetaChip(label: item.classification!),
              ],
            ),

            // Account name
            if (item.accountName != null) ...[
              const Gap(6),
              Text(
                item.accountName!,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 12,
                  color: AppColors.greyDark,
                  letterSpacing: 12 * 0.02,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const Gap(14),
            const Divider(height: 1),
            const Gap(12),

            // Finance summary row
            Row(
              children: [
                Expanded(
                  child: _FinanceTile(
                    label: 'Annual Revenue',
                    value: item.annualRevenue.formatCurrency(decimalDigits: 0),
                  ),
                ),
                Expanded(
                  child: _FinanceTile(
                    label: 'Tax Amount',
                    value: item.taxAmount.formatCurrency(decimalDigits: 0),
                  ),
                ),
                Expanded(
                  child: _FinanceTile(
                    label: 'Eff. Rate',
                    value: '${item.effectiveTaxRate.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),

            const Gap(12),

            // View details arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 4,
              children: [
                Text(
                  'View details',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                    letterSpacing: 12 * 0.02,
                  ),
                ),
                Icon(Icons.arrow_forward, size: 14, color: AppColors.greyDark),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'GeneralSans',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 10 * 0.02,
      ),
    ),
  );
}

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
    decoration: BoxDecoration(
      color: AppColors.greyLight,
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: 'GeneralSans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 11 * 0.02,
      ),
    ),
  );
}

class _FinanceTile extends StatelessWidget {
  final String label, value;
  const _FinanceTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 10,
          color: AppColors.greyDark,
          letterSpacing: 10 * 0.02,
        ),
      ),
      const Gap(2),
      Text(
        value,
        style: const TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 13 * 0.02,
        ),
      ),
    ],
  );
}

// ── Empty / error states ──────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.receipt_long_outlined, size: 52, color: AppColors.grey),
        const Gap(14),
        const Text(
          'No filings yet',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(6),
        Text(
          'Your completed and in-progress\ntax returns will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 13,
            color: AppColors.greyDark,
          ),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44, color: Colors.redAccent),
          const Gap(12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 13),
          ),
          const Gap(16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
