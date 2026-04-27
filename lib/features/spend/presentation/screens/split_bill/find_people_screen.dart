import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/split_bill.dart';

import 'split_bill_widgets.dart';

class FindPeopleScreen extends StatefulWidget {
  static const String path = '/find-people';

  const FindPeopleScreen({super.key});

  @override
  State<FindPeopleScreen> createState() => _FindPeopleScreenState();
}

class _FindPeopleScreenState extends State<FindPeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<SplitPerson> _people = [
    SplitPerson(name: 'Tolu Adeyemi', username: '@tolu'),
    SplitPerson(name: 'Chioma Okafor', username: '@chioma'),
    SplitPerson(name: 'Bolu Ibrahim', username: '@bolu'),
    SplitPerson(name: 'Kemi Adeleke', username: '@kemi'),
    SplitPerson(name: 'Femi Balogun', username: '@femi'),
    SplitPerson(name: 'Zainab Mohammed', username: '@zainab'),
  ];

  List<SplitPerson> get _filtered => _query.isEmpty
      ? _people
      : _people
            .where(
              (p) =>
                  p.name.toLowerCase().contains(_query) ||
                  p.username.toLowerCase().contains(_query),
            )
            .toList();

  int get _selectedCount => _people.where((p) => p.isIncluded).length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    const SplitBackButton(),
                    const Gap(24),
                    const Text(
                      'Find People',
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
                      'Add to your split bill',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'GeneralSans',
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Gap(20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                          const Gap(10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _query = v.toLowerCase()),
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'GeneralSans',
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search by name or username',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'GeneralSans',
                                  color: Colors.grey.shade400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Gap(8),
                        itemBuilder: (_, i) {
                          final person = _filtered[i];
                          return _PersonSelectTile(
                            person: person,
                            onTap: () => setState(
                              () => person.isIncluded = !person.isIncluded,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SplitBottomButton(
              label: _selectedCount > 0
                  ? 'Continue ($_selectedCount)'
                  : 'Continue',
              onTap: _selectedCount > 0
                  ? () => context.pop(
                      _people.where((p) => p.isIncluded).toList(),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonSelectTile extends StatelessWidget {
  final SplitPerson person;
  final VoidCallback onTap;

  const _PersonSelectTile({required this.person, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: person.isIncluded
                    ? const Color(0xFFFFC107)
                    : Colors.transparent,
                border: Border.all(
                  color: person.isIncluded
                      ? const Color(0xFFFFC107)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: person.isIncluded
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
