// lib/features/tools/presentation/screens/taxation/tax_filing/complex_paye_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/complex_paye_models.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/complex_paye_provider.dart';

class ComplexPayeHistoryScreen extends ConsumerWidget {
  static const String path = FilingRoutes.complexPayeHistory;

  const ComplexPayeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(complexPayeHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Complex Filing History'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(complexPayeHistoryProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e.toString().replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 14),
              ),
              const Gap(16),
              TextButton(
                onPressed: () =>
                    ref.read(complexPayeHistoryProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? _EmptyState(
                onRefresh: () =>
                    ref.read(complexPayeHistoryProvider.notifier).refresh(),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(complexPayeHistoryProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (context, i) => _HistoryCard(
                    item: items[i],
                    onTap: () => context.pushNamed(
                      FilingRoutes.complexPayeDetails,
                      pathParameters: {'id': items[i].id},
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// ── History card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final ComplexPayeHistoryItem item;
  final VoidCallback onTap;
  const _HistoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.businessName.isNotEmpty
                            ? item.businessName
                            : 'Pro / Complex Filing',
                        style: const TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'Tax Year ${item.year}',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 12,
                          color: AppColors.greyDark,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: item.status),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                if (item.filingFee > 0)
                  _MetaChip(
                    icon: Icons.receipt_long_outlined,
                    label: '₦${item.filingFee.formatCurrency()} fee',
                  ),
                if (item.filingFee > 0 && item.taxLiability > 0)
                  const SizedBox(width: 8),
                if (item.taxLiability > 0)
                  _MetaChip(
                    icon: Icons.account_balance_outlined,
                    label: '₦${item.taxLiability.formatCurrency()} tax',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final ComplexPayeStatus status;
  const _StatusBadge({required this.status});

  Color get _color => _statusColor(status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        status.displayLabel,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

Color _statusColor(ComplexPayeStatus s) {
  switch (s) {
    case ComplexPayeStatus.processing:
      return Colors.blue.shade700;
    case ComplexPayeStatus.assignedPrice:
      return const Color(0xFFB8900A);
    case ComplexPayeStatus.pendingPayment:
      return Colors.orange.shade800;
    case ComplexPayeStatus.finished:
      return Colors.green.shade700;
    case ComplexPayeStatus.rejected:
      return Colors.red.shade700;
    case ComplexPayeStatus.unknown:
      return Colors.grey.shade700;
  }
}

// ── Meta chip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.greyDark),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 12,
            color: AppColors.greyDark,
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_outlined, size: 56, color: AppColors.greyDark),
          const Gap(12),
          Text(
            'No complex filings yet',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark,
            ),
          ),
          const Gap(8),
          Text(
            'Filings you submit will appear here.',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              color: AppColors.greyDark,
            ),
          ),
          const Gap(20),
          TextButton(onPressed: onRefresh, child: const Text('Refresh')),
        ],
      ),
    );
  }
}
