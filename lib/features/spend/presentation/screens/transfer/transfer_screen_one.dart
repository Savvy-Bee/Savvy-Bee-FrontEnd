import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/beneficiary.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';

import '../../../../../core/utils/date_time_extension.dart';
import '../../../../../core/utils/num_extensions.dart';
import '../../providers/beneficiary_provider.dart';
import '../../providers/wallet_provider.dart';
import 'enter_amount_screen.dart';
import 'internal_transfer_screen.dart';
import 'send_money_screen.dart';
import 'transfer_history_screen.dart';
import 'transfer_screen.dart';
import '../transactions/transaction_details_screen.dart';

class TransferScreenOne extends ConsumerStatefulWidget {
  static const String path = '/transfer-screen-one';

  const TransferScreenOne({super.key});

  @override
  ConsumerState<TransferScreenOne> createState() => _TransferScreenOneState();
}

class _TransferScreenOneState extends ConsumerState<TransferScreenOne> {
  void _showAddBeneficiarySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddBeneficiarySheet(
        onAdd: (beneficiary) =>
            ref.read(beneficiaryProvider.notifier).add(beneficiary),
      ),
    );
  }

  void _showConfirmation(Beneficiary beneficiary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BeneficiaryConfirmationSheet(beneficiary: beneficiary),
    );
  }

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name.substring(0, name.length.clamp(0, 2)).toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final beneficiaries = ref.watch(beneficiaryProvider);
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Send Money',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Who are you sending to?',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Gap(20),

          // Beneficiaries Horizontal Scroll
          SizedBox(
            height: 110,
            child: Row(
              children: [
                // Add Button
                GestureDetector(
                  onTap: _showAddBeneficiarySheet,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: const Center(child: Icon(Icons.add, size: 32, color: Colors.grey)),
                      ),
                      const Gap(8),
                      const Text('Add', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const Gap(16),

                // Scrollable Beneficiaries
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: beneficiaries.map((b) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: () => _showConfirmation(b),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.grey.shade100,
                                  child: Text(
                                    _initials(b.name),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  b.name,
                                  style: const TextStyle(fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(32),

          // Send to any bank account
          _SendToBankTile(onTap: () => context.push(TransferScreen.path)),

          const Gap(12),

          // Send to Savvy Bee user
          _SendToSavvyBeeTile(onTap: () => context.push(InternalTransferScreen.path)),

          const Gap(32),

          // Recent Transactions (new design)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () => context.push(TransferHistoryScreen.path),
                child: const Text('See all'),
              ),
            ],
          ),
          const Gap(12),

          transactionsAsync.when(
            data: (response) {
              final recent = (response.data?.transactions ?? []).take(3).toList();
              if (recent.isEmpty) {
                return const Center(child: Text('No recent transactions'));
              }
              return Column(
                children: recent.map((tx) => _RecentTransactionCard(
                  transaction: tx,
                  onTap: () => context.pushNamed(TransactionDetailScreen.path, extra: tx),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Failed to load recent')),
          ),
        ],
      ),
    );
  }
}

// ==================== ADD BENEFICIARY BOTTOM SHEET ====================
class _AddBeneficiarySheet extends StatefulWidget {
  final Function(Beneficiary) onAdd;

  const _AddBeneficiarySheet({required this.onAdd});

  @override
  State<_AddBeneficiarySheet> createState() => _AddBeneficiarySheetState();
}

class _AddBeneficiarySheetState extends State<_AddBeneficiarySheet> {
  static const _banks = [
    'Access Bank', 'First Bank', 'GTBank', 'Kuda Bank', 'Opay',
    'PalmPay', 'Sterling Bank', 'UBA', 'Zenith Bank',
  ];

  bool _isSavvyBee = true;
  final _usernameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  String? _selectedBank;

  @override
  void dispose() {
    _usernameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Beneficiary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const Gap(20),

            // Toggle
            Row(
              children: [
                Expanded(
                  child: _OptionButton(
                    text: 'Savvy Bee Friend',
                    isSelected: _isSavvyBee,
                    onTap: () => setState(() => _isSavvyBee = true),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _OptionButton(
                    text: 'Bank Account',
                    isSelected: !_isSavvyBee,
                    onTap: () => setState(() => _isSavvyBee = false),
                  ),
                ),
              ],
            ),

            const Gap(24),

            if (_isSavvyBee) ...[
              const Text('Username'),
              const Gap(8),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(hintText: '@username'),
              ),
            ] else ...[
              const Text('Select Bank'),
              DropdownButtonFormField<String>(
                value: _selectedBank,
                items: _banks
                    .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedBank = val),
                hint: const Text('Choose bank'),
              ),
              const Gap(16),
              const Text('Account Number'),
              TextField(controller: _accountNumberController, keyboardType: TextInputType.number),
              const Gap(16),
              const Text('Account Name'),
              TextField(controller: _accountNameController),
            ],

            const Gap(32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_isSavvyBee && _usernameController.text.isNotEmpty) {
                    widget.onAdd(Beneficiary(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _usernameController.text,
                      username: _usernameController.text,
                    ));
                  } else if (!_isSavvyBee &&
                      _selectedBank != null &&
                      _accountNumberController.text.isNotEmpty &&
                      _accountNameController.text.isNotEmpty) {
                    widget.onAdd(Beneficiary(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _accountNameController.text,
                      accountNumber: _accountNumberController.text,
                      bankName: _selectedBank,
                    ));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Add Beneficiary'),
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

// ==================== CONFIRMATION SHEET ====================
class _BeneficiaryConfirmationSheet extends StatelessWidget {
  final Beneficiary beneficiary;

  const _BeneficiaryConfirmationSheet({required this.beneficiary});

  @override
  Widget build(BuildContext context) {
    final subtitle = beneficiary.isSavvyBee
        ? '@${beneficiary.username}'
        : '${beneficiary.accountNumber} · ${beneficiary.bankName}';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Send to ${beneficiary.name}?',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                    if (beneficiary.isSavvyBee) {
                      context.push(
                        InternalTransferScreen.path,
                        extra: beneficiary.username,
                      );
                    } else if (beneficiary.accountNumber != null &&
                        beneficiary.bankName != null) {
                      context.pushNamed(
                        EnterAmountScreen.path,
                        extra: RecipientAccountInfo(
                          accountName: beneficiary.name,
                          accountNumber: beneficiary.accountNumber!,
                          bankName: beneficiary.bankName!,
                          bankCode: beneficiary.bankCode ?? '',
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
        ],
      ),
    );
  }
}

// ==================== RECENT TRANSACTION CARD (new UI) ====================
class _RecentTransactionCard extends StatelessWidget {
  final WalletTransaction transaction;
  final VoidCallback onTap;

  const _RecentTransactionCard({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final initials = transaction.narration.isNotEmpty
        ? transaction.narration.substring(0, 2).toUpperCase()
        : '??';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade100,
              child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.narration.isNotEmpty ? transaction.narration : transaction.transactionFor,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    isCredit ? 'Received' : 'Sent',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}${transaction.amount.formatCurrency(decimalDigits: 0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  transaction.createdAt.formatRelative(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Keep your existing _SendToBankTile and _SendToSavvyBeeTile widgets (they remain the same)
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.account_balance, color: Colors.grey),
              Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Send to any bank account', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('Send to a local bank', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendToSavvyBeeTile extends StatelessWidget {
  final VoidCallback onTap;
  const _SendToSavvyBeeTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.person, color: Colors.grey),
              Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Send to Savvy Bee user', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('Send by username', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../../core/theme/app_colors.dart';
// import '../../../../../core/utils/assets/assets.dart';
// import '../../../../../core/utils/date_time_extension.dart';
// import '../../../../../core/utils/num_extensions.dart';
// import '../../../../../core/widgets/custom_button.dart';
// import '../../providers/wallet_provider.dart';
// import 'internal_transfer_screen.dart';
// import 'send_money_screen.dart';
// import 'transfer_history_screen.dart';
// import 'transfer_screen.dart';
// import '../transactions/transaction_details_screen.dart';

// class TransferScreenOne extends ConsumerWidget {
//   static const String path = '/transfer-screen-one';

//   const TransferScreenOne({super.key});

//   // Mock beneficiaries — replace with real data when API is available
//   static const _beneficiaries = [
//     ('AT', 'Aegon\nTargaryen', '0123456789', 'Access Bank', '044'),
//     ('SS', 'Savvy Super\nMart', '0987654321', 'GTBank', '058'),
//   ];

//   void _showConfirmation(
//     BuildContext context, {
//     required String accountName,
//     required String accountNumber,
//     required String bankName,
//     required String bankCode,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => _BeneficiaryConfirmationSheet(
//         accountName: accountName,
//         accountNumber: accountNumber,
//         bankName: bankName,
//         bankCode: bankCode,
//       ),
//     );
//   }

//   /// Returns up to 2 uppercase letters derived from the narration string.
//   String _initials(String narration) {
//     final words = narration.trim().split(RegExp(r'\s+'));
//     if (words.length >= 2) {
//       return '${words[0][0]}${words[1][0]}'.toUpperCase();
//     } else if (words.isNotEmpty && words[0].isNotEmpty) {
//       final w = words[0];
//       return w.substring(0, w.length >= 2 ? 2 : 1).toUpperCase();
//     }
//     return '?';
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final transactionsAsync = ref.watch(transactionListProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Send Money'),
//         leading: BackButton(onPressed: () => context.pop()),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//         children: [
//           // ── BENEFICIARIES ─────────────────────────────────────
//           _SectionLabel('BENEFICIARIES'),
//           const Gap(12),
//           Row(
//             spacing: 16,
//             children: _beneficiaries
//                 .map(
//                   (b) => _AvatarChip(
//                     initials: b.$1,
//                     label: b.$2,
//                     onTap: () => _showConfirmation(
//                       context,
//                       accountName: b.$2.replaceAll('\n', ' '),
//                       accountNumber: b.$3,
//                       bankName: b.$4,
//                       bankCode: b.$5,
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ),
//           const Gap(20),

//           // ── SEND TO ANY BANK ──────────────────────────────────
//           _SendToBankTile(
//             onTap: () => context.push(TransferScreen.path),
//           ),
//           const Gap(12),

//           // ── SEND TO SAVVY BEE USER ────────────────────────────
//           _SendToSavvyBeeTile(
//             onTap: () => context.push(InternalTransferScreen.path),
//           ),
//           const Gap(24),

//           // ── SAVVY BEE FRIENDS ─────────────────────────────────
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _SectionLabel('SAVVY BEE FRIENDS'),
//               TextButton(
//                 onPressed: null,
//                 child: Text(
//                   'See all',
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
//                 ),
//               ),
//             ],
//           ),
//           const Gap(8),
//           _SavvyBeeFriendsEmptyState(),
//           const Gap(24),

//           // ── RECENT TRANSACTIONS ───────────────────────────────
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _SectionLabel('RECENT TRANSACTIONS'),
//               TextButton(
//                 onPressed: () => context.push(TransferHistoryScreen.path),
//                 child: const Text(
//                   'See all',
//                   style: TextStyle(fontSize: 12, color: AppColors.primary),
//                 ),
//               ),
//             ],
//           ),
//           const Gap(8),
//           transactionsAsync.when(
//             data: (apiResponse) {
//               final recent =
//                   (apiResponse.data?.transactions ?? []).take(3).toList();
//               if (recent.isEmpty) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   child: Center(
//                     child: Text(
//                       'No recent transactions',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ),
//                 );
//               }
//               return Column(
//                 children: recent
//                     .map(
//                       (tx) => _RecentTxTile(
//                         initials: _initials(tx.narration),
//                         name: tx.narration,
//                         subtitle:
//                             '${tx.isCredit ? 'You received' : 'You sent'} '
//                             '${tx.amount.formatCurrency(decimalDigits: 0)} '
//                             '${tx.createdAt.formatRelative()}',
//                         onTap: () => context.pushNamed(
//                           TransactionDetailScreen.path,
//                           extra: tx,
//                         ),
//                       ),
//                     )
//                     .toList(),
//               );
//             },
//             loading: () => const Padding(
//               padding: EdgeInsets.symmetric(vertical: 16),
//               child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
//             ),
//             error: (_, __) => const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Beneficiary confirmation bottom sheet ────────────────────────────────────

// class _BeneficiaryConfirmationSheet extends StatelessWidget {
//   final String accountName;
//   final String accountNumber;
//   final String bankName;
//   final String bankCode;

//   const _BeneficiaryConfirmationSheet({
//     required this.accountName,
//     required this.accountNumber,
//     required this.bankName,
//     required this.bankCode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 48),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Gap(12),
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const Gap(24),
//           SvgPicture.asset(Assets.bankSvg),
//           const Gap(24),
//           Text(
//             accountName,
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//           const Gap(16),
//           Text.rich(
//             textAlign: TextAlign.center,
//             TextSpan(
//               text: 'You are sending to ',
//               children: [
//                 TextSpan(
//                   text: '$accountName ($bankName)',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const TextSpan(text: '. Is this correct?'),
//               ],
//               style: const TextStyle(fontSize: 12),
//             ),
//           ),
//           const Gap(24),
//           Row(
//             children: [
//               Expanded(
//                 child: CustomOutlinedButton(
//                   text: 'Cancel',
//                   onPressed: () => context.pop(),
//                 ),
//               ),
//               const Gap(8),
//               Expanded(
//                 child: CustomElevatedButton(
//                   text: 'Confirm',
//                   buttonColor: CustomButtonColor.black,
//                   onPressed: () {
//                     context.pop();
//                     context.pushNamed(
//                       SendMoneyScreen.path,
//                       extra: RecipientAccountInfo(
//                         accountName: accountName,
//                         accountNumber: accountNumber,
//                         bankName: bankName,
//                         bankCode: bankCode,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Savvy Bee Friends empty state ────────────────────────────────────────────

// class _SavvyBeeFriendsEmptyState extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.people_outline, size: 36, color: Colors.grey.shade400),
//           const Gap(8),
//           Text(
//             'No Savvy Bee friends yet',
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const Gap(4),
//           Text(
//             'Friends who use Savvy Bee will appear here',
//             style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Small helpers ────────────────────────────────────────────────────────────

// class _SectionLabel extends StatelessWidget {
//   final String text;
//   const _SectionLabel(this.text);

//   @override
//   Widget build(BuildContext context) => Text(
//         text,
//         style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           letterSpacing: 0.5,
//           color: AppColors.textSecondary,
//         ),
//       );
// }

// class _AvatarChip extends StatelessWidget {
//   final String initials;
//   final String label;
//   final VoidCallback onTap;
//   const _AvatarChip({
//     required this.initials,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: Colors.transparent,
//             child: Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.black, width: 1.5),
//               ),
//               child: Center(
//                 child: Text(
//                   initials,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const Gap(6),
//           Text(
//             label,
//             maxLines: 2,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 10, height: 1.3),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SendToBankTile extends StatelessWidget {
//   final VoidCallback onTap;
//   const _SendToBankTile({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade200),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.send_rounded,
//                 size: 20,
//                 color: AppColors.textSecondary,
//               ),
//               const Gap(14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     Text(
//                       'Send to any bank account',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Gap(2),
//                     Text(
//                       'Send to a local bank',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.chevron_right_rounded, size: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SendToSavvyBeeTile extends StatelessWidget {
//   final VoidCallback onTap;
//   const _SendToSavvyBeeTile({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade200),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.people_alt_outlined,
//                 size: 20,
//                 color: AppColors.textSecondary,
//               ),
//               const Gap(14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     Text(
//                       'Send to Savvy Bee user',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Gap(2),
//                     Text(
//                       'Send by Savvy Bee username',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.chevron_right_rounded, size: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RecentTxTile extends StatelessWidget {
//   final String initials;
//   final String name;
//   final String subtitle;
//   final VoidCallback onTap;

//   const _RecentTxTile({
//     required this.initials,
//     required this.name,
//     required this.subtitle,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ListTile(
//           contentPadding: EdgeInsets.zero,
//           leading: Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.black, width: 1.5),
//             ),
//             child: Center(
//               child: Text(
//                 initials,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//           title: Text(
//             name,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           subtitle: Text(
//             subtitle,
//             style: const TextStyle(
//               fontSize: 12,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           trailing: const Icon(Icons.chevron_right_rounded, size: 20),
//           onTap: onTap,
//         ),
//         Divider(height: 1, color: Colors.grey.shade100),
//       ],
//     );
//   }
// }
