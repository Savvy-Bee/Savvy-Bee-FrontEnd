// lib/features/tools/presentation/screens/taxation/tax_filing/filing_country_select.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

// ── Country data ──────────────────────────────────────────────────────────────

class _Country {
  final String code;
  final String flag;
  final String name;
  final String subtitle;

  const _Country({
    required this.code,
    required this.flag,
    required this.name,
    required this.subtitle,
  });
}

const _countries = [
  _Country(
    code: 'ng',
    flag: '🇳🇬',
    name: 'Nigeria',
    subtitle: 'PAYE & personal income tax filing',
  ),
  _Country(
    code: 'uk',
    flag: '🇬🇧',
    name: 'United Kingdom',
    subtitle: 'Income tax with standard allowance',
  ),
  _Country(
    code: 'us',
    flag: '🇺🇸',
    name: 'United States',
    subtitle: 'Federal income tax (bracket-based)',
  ),
  _Country(
    code: 'fr',
    flag: '🇫🇷',
    name: 'France',
    subtitle: 'Impôt sur le revenu',
  ),
  _Country(
    code: 'ci',
    flag: '🇨🇮',
    name: "Côte d'Ivoire",
    subtitle: 'Impôt sur les revenus',
  ),
  _Country(
    code: 'sn',
    flag: '🇸🇳',
    name: 'Senegal',
    subtitle: 'Impôt sur les revenus',
  ),
  _Country(
    code: 'cd',
    flag: '🇨🇩',
    name: 'DR Congo',
    subtitle: 'Impôt sur les revenus professionnels',
  ),
  _Country(
    code: 'cm',
    flag: '🇨🇲',
    name: 'Cameroon',
    subtitle: 'Impôt sur le revenu des personnes physiques',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class FilingCountrySelectScreen extends ConsumerStatefulWidget {
  static const String path = FilingRoutes.filingCountrySelect;

  const FilingCountrySelectScreen({super.key});

  @override
  ConsumerState<FilingCountrySelectScreen> createState() =>
      _FilingCountrySelectScreenState();
}

class _FilingCountrySelectScreenState
    extends ConsumerState<FilingCountrySelectScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(filingCountryProvider);
  }

  void _onContinue() {
    ref.read(filingCountryProvider.notifier).state = _selected;
    context.pushNamed(FilingRoutes.step1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Select Country'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              children: [
                // ── Headline ────────────────────────────────────────────
                const Text(
                  'Where are you filing from?',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 24 * 0.02,
                  ),
                ),
                const Gap(8),
                Text(
                  'We will apply the correct tax rules and rates for your country.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    color: AppColors.greyDark,
                    letterSpacing: 13 * 0.02,
                  ),
                ),
                const Gap(24),

                // ── Country tiles ────────────────────────────────────────
                ..._countries.map(
                  (c) => _CountryTile(
                    country: c,
                    isSelected: _selected == c.code,
                    onTap: () => setState(() => _selected = c.code),
                  ),
                ),
                const Gap(8),
              ],
            ),
          ),

          // ── CTA ──────────────────────────────────────────────────────
          BottomActionButton(
            label: 'Continue',
            onTap: _onContinue,
          ),
        ],
      ),
    );
  }
}

// ── Tile widget ───────────────────────────────────────────────────────────────

class _CountryTile extends StatelessWidget {
  final _Country country;
  final bool isSelected;
  final VoidCallback onTap;

  const _CountryTile({
    required this.country,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFBEB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF5C842) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 28)),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    country.subtitle,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFF5C842) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF5C842)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
