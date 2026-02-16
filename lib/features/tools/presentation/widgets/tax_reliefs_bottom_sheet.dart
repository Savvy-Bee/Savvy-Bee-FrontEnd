import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

class TaxReliefsBottomSheet extends StatelessWidget {
  const TaxReliefsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const TaxReliefsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nigerian Tax Reliefs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close),
                      constraints: const BoxConstraints(),
                      style: Constants.collapsedButtonStyle,
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildReliefSection(
                      'Personal Relief',
                      'The Personal Relief is set at the higher of 1% of gross income or ₦200,000 + 20% of gross income (minimum relief of ₦200,000).',
                      Icons.person_outline,
                      AppColors.primary,
                    ),
                    const Gap(16),
                    _buildReliefSection(
                      'Consolidated Relief Allowance (CRA)',
                      'This is calculated as 1% of gross income or ₦200,000, whichever is higher, plus 20% of gross income.',
                      Icons.calculate_outlined,
                      AppColors.info,
                    ),
                    const Gap(16),
                    _buildReliefSection(
                      'National Housing Fund (NHF)',
                      'Employees can claim relief on contributions to the National Housing Fund, capped at 2.5% of their basic salary.',
                      Icons.home_outlined,
                      AppColors.success,
                    ),
                    const Gap(16),
                    _buildReliefSection(
                      'Pension Contributions',
                      'Contributions to approved pension schemes are tax-deductible, with a minimum of 8% of basic salary + transport + housing allowances.',
                      Icons.savings_outlined,
                      AppColors.warning,
                    ),
                    const Gap(16),
                    _buildReliefSection(
                      'Life Assurance Premiums',
                      'Premiums paid for life assurance policies are eligible for relief, capped at 10% of gross income or ₦500,000, whichever is lower.',
                      Icons.security_outlined,
                      AppColors.yellow,
                    ),
                    const Gap(16),
                    _buildReliefSection(
                      'Gratuity Relief',
                      'Gratuities are exempt from tax up to ₦10,000,000 per annum. Amounts above this threshold are taxable.',
                      Icons.card_giftcard_outlined,
                      AppColors.error.withOpacity(0.7),
                    ),
                    const Gap(16),
                    _buildReliefSection(
                      'Leave Grant Relief',
                      'Leave grants are tax-exempt up to 10% of basic salary or ₦500,000 per annum, whichever is lower.',
                      Icons.beach_access_outlined,
                      AppColors.grey,
                    ),
                    const Gap(16),
                    _buildReliefSection(
                      'Medical Expenses',
                      'Reasonable medical expenses for the employee and up to 4 dependents are tax-deductible when supported by medical receipts.',
                      Icons.medical_services_outlined,
                      Colors.red.shade400,
                    ),
                    const Gap(16),
                    _buildReliefSection(
                      'Disabled Persons Relief',
                      'Persons with disabilities are entitled to an additional relief allowance as provided under the Personal Income Tax Act.',
                      Icons.accessible_outlined,
                      Colors.purple.shade400,
                    ),
                    const Gap(16),
                    _buildImportantNote(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReliefSection(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Note',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
                const Gap(8),
                Text(
                  'Tax reliefs are subject to the provisions of the Personal Income Tax Act (PITA) and may vary based on state regulations. Always consult with a qualified tax professional for personalized advice.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade900,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}