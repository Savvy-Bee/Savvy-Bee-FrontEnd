import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/split_bill.dart';

import 'approval_status_screen.dart';
import 'find_people_screen.dart';
import 'split_bill_widgets.dart';

class SplitBillScreen extends StatefulWidget {
  static const String path = '/split-bill';
  final List<SplitPerson> selectedPeople;
  final double totalAmount;

  const SplitBillScreen({
    super.key,
    this.selectedPeople = const [],
    this.totalAmount = 15000,
  });

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  late List<SplitPerson> _included;

  @override
  void initState() {
    super.initState();
    if (widget.selectedPeople.isEmpty) {
      _included = [
        SplitPerson(
          name: 'Tolu Adeyemi',
          username: '@tolu',
          isIncluded: true,
        ),
        SplitPerson(
          name: 'Chioma Okafor',
          username: '@chioma',
          isIncluded: true,
        ),
      ];
    } else {
      _included = widget.selectedPeople
          .asMap()
          .entries
          .map(
            (e) => SplitPerson(
              name: e.value.name,
              username: e.value.username,
              isIncluded: e.key < 2,
            ),
          )
          .toList();
    }
  }

  int get _splitCount =>
      _included.where((p) => p.isIncluded).length + 1; // +1 for self

  double get _perPerson =>
      _splitCount > 0 ? widget.totalAmount / _splitCount : widget.totalAmount;

  String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return '₦${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
    }
    return '₦${amount.toStringAsFixed(2)}';
  }

  Future<void> _findMorePeople() async {
    final added = await context.push<List<SplitPerson>>(FindPeopleScreen.path);
    if (added != null && added.isNotEmpty && mounted) {
      setState(() {
        for (final person in added) {
          if (!_included.any((p) => p.username == person.username)) {
            _included.add(
              SplitPerson(
                name: person.name,
                username: person.username,
                isIncluded: true,
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final includedPeople = _included.where((p) => p.isIncluded).toList();

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
                      'Split Bill',
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
                      'Share the cost',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'GeneralSans',
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Gap(20),

                    // Summary card
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
                          Text(
                            'Total amount',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            '₦ ${widget.totalAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'GeneralSans',
                              color: Colors.black,
                              letterSpacing: -1,
                            ),
                          ),
                          const Gap(16),
                          Divider(color: Colors.grey.shade100, height: 1),
                          const Gap(12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Split $_splitCount ways',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'GeneralSans',
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                _formatAmount(_perPerson),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'GeneralSans',
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Gap(4),
                          Text(
                            'Each person pays',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(24),
                    const Text(
                      'Split with',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                    const Gap(12),

                    // People tiles
                    ..._included.map(
                      (person) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SplitPersonTile(
                          person: person,
                          onToggle: () => setState(
                            () => person.isIncluded = !person.isIncluded,
                          ),
                        ),
                      ),
                    ),

                    // Find more people
                    GestureDetector(
                      onTap: _findMorePeople,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8EC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE9B0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFC107),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(12),
                            const Text(
                              'Find more people',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'GeneralSans',
                                color: Color(0xFF7A5C00),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Gap(24),
                  ],
                ),
              ),
            ),
            SplitBottomButton(
              label: 'Continue',
              onTap: includedPeople.isNotEmpty
                  ? () => context.push(
                      ApprovalStatusScreen.path,
                      extra: {
                        'people': includedPeople,
                        'total': widget.totalAmount,
                        'perPerson': _perPerson,
                      },
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitPersonTile extends StatelessWidget {
  final SplitPerson person;
  final VoidCallback onToggle;

  const _SplitPersonTile({required this.person, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: person.isIncluded ? const Color(0xFFFFF8EC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: person.isIncluded
              ? const Color(0xFFFFE9B0)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: person.isIncluded
                  ? const Color(0xFFFFE9B0)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 18,
              color: person.isIncluded
                  ? const Color(0xFFFFC107)
                  : Colors.grey.shade400,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'GeneralSans',
                    color: Colors.black,
                  ),
                ),
                const Gap(2),
                Text(
                  person.username,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'GeneralSans',
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: person.isIncluded
                    ? const Color(0xFFFFC107)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: person.isIncluded
                      ? const Color(0xFFFFC107)
                      : Colors.grey.shade300,
                ),
              ),
              child: Icon(
                person.isIncluded ? Icons.remove : Icons.add,
                size: 16,
                color: person.isIncluded ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
