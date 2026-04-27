import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/split_bill.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/success_screen.dart';

import 'split_bill_widgets.dart';

class PaymentToScreen extends StatefulWidget {
  static const String path = '/payment-to';
  final List<SplitPerson> people;
  final double total;
  final double perPerson;

  const PaymentToScreen({
    super.key,
    required this.people,
    required this.total,
    required this.perPerson,
  });

  @override
  State<PaymentToScreen> createState() => _PaymentToScreenState();
}

class _PaymentToScreenState extends State<PaymentToScreen> {
  final List<SavedAccount> _accounts = [
    SavedAccount(
      type: 'Personal',
      name: 'Adebayo Ogunleye',
      bank: 'Zenith Bank',
      accountNumber: '2034567890',
    ),
    SavedAccount(
      type: 'Business',
      name: 'Jollof Palace Restaurant',
      bank: 'GTBank',
      accountNumber: '0123456789',
    ),
  ];

  int get _splitCount => widget.people.length + 1;

  String _formatAmount(double amount) =>
      '₦${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final hasSelection = _accounts.any((a) => a.isSelected);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    const SplitBackButton(),
                    const Gap(24),
                    const Text(
                      'Payment To',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Where should the money go?',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'GeneralSans',
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Gap(20),

                    // Split total card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Split total',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'GeneralSans',
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                '$_splitCount people',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'GeneralSans',
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          const Gap(6),
                          Text(
                            _formatAmount(widget.total),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'GeneralSans',
                              color: Colors.black,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(24),
                    const Text(
                      'Select destination',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                    const Gap(12),

                    // Account tiles
                    ..._accounts.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AccountTile(
                          account: account,
                          onTap: () => setState(() {
                            for (final a in _accounts) {
                              a.isSelected = false;
                            }
                            account.isSelected = true;
                          }),
                        ),
                      ),
                    ),

                    // Add new account
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add New Account',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'GeneralSans',
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Bank account or mobile money',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'GeneralSans',
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Gap(16),

                    // Payment collection note
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE9B0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.credit_card_outlined,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Payment collection',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'GeneralSans',
                                    color: Colors.black,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  'Once everyone approves, their shares will be collected and sent to this account.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'GeneralSans',
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(24),
                  ],
                ),
              ),
            ),
            SplitBottomButton(
              label: 'Confirm & Send Requests',
              onTap: hasSelection
                  ? () => context.pushReplacement(SendSuccessScreen.path)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final SavedAccount account;
  final VoidCallback onTap;

  const _AccountTile({required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: account.isSelected
                ? const Color(0xFFE0C97F)
                : Colors.grey.shade200,
            width: account.isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                account.type == 'Personal'
                    ? Icons.person_outline
                    : Icons.store_outlined,
                size: 18,
                color: Colors.grey.shade500,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.type,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'GeneralSans',
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GeneralSans',
                      color: Colors.black,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    '${account.bank} • ${account.accountNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GeneralSans',
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: account.isSelected
                    ? const Color(0xFFFFC107)
                    : Colors.transparent,
                border: Border.all(
                  color: account.isSelected
                      ? const Color(0xFFFFC107)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: account.isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
