import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/widgets/custom_button.dart';
import 'send_money_screen.dart';
import 'transfer_screen.dart';

class TransferScreenOne extends ConsumerWidget {
  static const String path = '/transfer-screen-one';

  const TransferScreenOne({super.key});

  // Mock data — replace with real providers
  static const _beneficiaries = [
    ('AT', 'Aegon\nTargaryen', '0123456789', 'Access Bank', '044'),
    ('SS', 'Savvy Super\nMart', '0987654321', 'GTBank', '058'),
  ];

  static const _friends = [
    ('SS', 'Savvy Super\nMart', '0987654321', 'GTBank', '058'),
    ('TO', 'Tunwase\nOsinaike', '0234567890', 'Zenith Bank', '057'),
    ('DC', 'Deborah\nCaulcrick', '0345678901', 'First Bank', '011'),
    ('VA', 'Victor\nAdabra', '0456789012', 'UBA', '033'),
    ('TI', 'Tamilon\nIdowu', '0567890123', 'Sterling Bank', '232'),
  ];

  static const _recentTx = [
    (
      'TO',
      'Tunwase Osinaike',
      'You sent ₦500,000 2 days ago',
      '0234567890',
      'Zenith Bank',
      '057',
    ),
    (
      'DC',
      'Deborah Caulcrick',
      'You sent ₦500,000 2 days ago',
      '0345678901',
      'First Bank',
      '011',
    ),
    (
      'SS',
      'Savvy Super Mart',
      'You sent ₦50,000 3 days ago',
      '0987654321',
      'GTBank',
      '058',
    ),
  ];

  void _showConfirmation(
    BuildContext context, {
    required String accountName,
    required String accountNumber,
    required String bankName,
    required String bankCode,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BeneficiaryConfirmationSheet(
        accountName: accountName,
        accountNumber: accountNumber,
        bankName: bankName,
        bankCode: bankCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── BENEFICIARIES ─────────────────────────────────────
          _SectionLabel('BENEFICIARIES'),
          const Gap(12),
          Row(
            spacing: 16,
            children: _beneficiaries
                .map(
                  (b) => _AvatarChip(
                    initials: b.$1,
                    label: b.$2,
                    onTap: () => _showConfirmation(
                      context,
                      accountName: b.$2.replaceAll('\n', ' '),
                      accountNumber: b.$3,
                      bankName: b.$4,
                      bankCode: b.$5,
                    ),
                  ),
                )
                .toList(),
          ),
          const Gap(20),

          // ── SEND TO ANY BANK ──────────────────────────────────
          _SendToBankTile(
            onTap: () => context.pushNamed(TransferScreen.path),
          ),
          const Gap(24),

          // ── SAVVY BEE FRIENDS ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel('SAVVY BEE FRIENDS'),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const Gap(8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 20,
              children: _friends
                  .map(
                    (f) => _AvatarChip(
                      initials: f.$1,
                      label: f.$2,
                      onTap: () => _showConfirmation(
                        context,
                        accountName: f.$2.replaceAll('\n', ' '),
                        accountNumber: f.$3,
                        bankName: f.$4,
                        bankCode: f.$5,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Gap(24),

          // ── RECENT TRANSACTIONS ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel('RECENT TRANSACTIONS'),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const Gap(8),
          ..._recentTx.map(
            (tx) => _RecentTxTile(
              initials: tx.$1,
              name: tx.$2,
              subtitle: tx.$3,
              onTap: () => _showConfirmation(
                context,
                accountName: tx.$2,
                accountNumber: tx.$4,
                bankName: tx.$5,
                bankCode: tx.$6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Beneficiary confirmation bottom sheet ────────────────────────────────────

class _BeneficiaryConfirmationSheet extends StatelessWidget {
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String bankCode;

  const _BeneficiaryConfirmationSheet({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.bankCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(24),
          SvgPicture.asset(Assets.bankSvg),
          const Gap(24),
          Text(
            accountName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: 'You are sending to ',
              children: [
                TextSpan(
                  text: '$accountName ($bankName)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '. Is this correct?'),
              ],
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: CustomOutlinedButton(
                  text: 'Cancel',
                  onPressed: () => context.pop(),
                ),
              ),
              const Gap(8),
              Expanded(
                child: CustomElevatedButton(
                  text: 'Confirm',
                  buttonColor: CustomButtonColor.black,
                  onPressed: () {
                    context.pop();
                    context.pushNamed(
                      SendMoneyScreen.path,
                      extra: RecipientAccountInfo(
                        accountName: accountName,
                        accountNumber: accountNumber,
                        bankName: bankName,
                        bankCode: bankCode,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Small helpers ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.textSecondary,
        ),
      );
}

class _AvatarChip extends StatelessWidget {
  final String initials;
  final String label;
  final VoidCallback onTap;
  const _AvatarChip({
    required this.initials,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const Gap(6),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _SendToBankTile extends StatelessWidget {
  final VoidCallback onTap;
  const _SendToBankTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.send_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Send to any bank account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Gap(2),
                    Text(
                      'Send to a local bank',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTxTile extends StatelessWidget {
  final String initials;
  final String name;
  final String subtitle;
  final VoidCallback onTap;

  const _RecentTxTile({
    required this.initials,
    required this.name,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: onTap,
        ),
        Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }
}
