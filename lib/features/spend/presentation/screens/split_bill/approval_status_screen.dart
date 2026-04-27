import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/split_bill.dart';

import 'payment_to_screen.dart';
import 'split_bill_widgets.dart';

class ApprovalStatusScreen extends StatelessWidget {
  static const String path = '/approval-status';
  final List<SplitPerson> people;
  final double total;
  final double perPerson;

  const ApprovalStatusScreen({
    super.key,
    required this.people,
    required this.total,
    required this.perPerson,
  });

  String _formatAmount(double amount) =>
      '₦${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    // Simulate: You + first person approved, rest pending
    final participants = <Map<String, dynamic>>[
      {'name': 'You', 'status': SplitStatus.approved},
      ...people.asMap().entries.map(
        (e) => {
          'name': e.value.name,
          'status': e.key == 0 ? SplitStatus.approved : SplitStatus.pending,
        },
      ),
    ];

    final pendingCount = participants
        .where((p) => p['status'] == SplitStatus.pending)
        .length;

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
                      'Approval Status',
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
                      'Waiting for confirmation',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'GeneralSans',
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Gap(20),

                    // Total card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            _formatAmount(total),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'GeneralSans',
                              color: Colors.black,
                              letterSpacing: -1,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Dinner at Jollof Palace',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(16),
                          Divider(color: Colors.grey.shade100, height: 1),
                          const Gap(12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your share',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'GeneralSans',
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _formatAmount(perPerson),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'GeneralSans',
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Gap(12),

                    // Pending banner
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8EC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE9B0)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: Colors.orange.shade600,
                            ),
                            const Gap(8),
                            Text(
                              '$pendingCount ${pendingCount == 1 ? 'person has' : 'people have'} not responded yet',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'GeneralSans',
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Gap(24),
                    const Text(
                      'Participants',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                    const Gap(12),

                    // Participant tiles
                    ...participants.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ParticipantTile(
                          name: p['name'] as String,
                          status: p['status'] as SplitStatus,
                        ),
                      ),
                    ),

                    // Share Split Key
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Share Split Key',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'GeneralSans',
                                    color: Colors.black,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  'Let others join with a unique code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'GeneralSans',
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
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
              label: 'Continue to Payment',
              onTap: () => context.push(
                PaymentToScreen.path,
                extra: {
                  'people': people,
                  'total': total,
                  'perPerson': perPerson,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final String name;
  final SplitStatus status;

  const _ParticipantTile({required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    final isApproved = status == SplitStatus.approved;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const SplitAvatarCircle(),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'GeneralSans',
                    color: Colors.black,
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(
                      isApproved
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked,
                      size: 14,
                      color: isApproved
                          ? const Color(0xFF4CAF50)
                          : Colors.orange.shade400,
                    ),
                    const Gap(4),
                    Text(
                      isApproved ? 'Approved' : 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'GeneralSans',
                        color: isApproved
                            ? const Color(0xFF4CAF50)
                            : Colors.orange.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
