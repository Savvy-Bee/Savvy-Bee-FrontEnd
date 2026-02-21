import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class SavingsTargetWidget extends StatelessWidget {
  final String savingsInsight;

  const SavingsTargetWidget({super.key, required this.savingsInsight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const Gap(12),
              const Expanded(
                child: Text(
                  'Savings Target',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 16 * 0.02,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),

          // Insight text
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryFaint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.warning,
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    savingsInsight.isNotEmpty
                        ? savingsInsight
                        : 'Set up savings goals to track your progress and build wealth over time.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.4,
                      fontFamily: 'GeneralSans',
                      letterSpacing: 12 * 0.02,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Goals',
                  '0',
                  Icons.flag_outlined,
                  AppColors.info.withOpacity(0.1),
                  AppColors.info,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildStatCard(
                  'Total Saved',
                  '₦0',
                  Icons.account_balance_wallet_outlined,
                  AppColors.success.withOpacity(0.1),
                  AppColors.success,
                ),
              ),
            ],
          ),
          const Gap(16),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to savings goals
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Set Savings Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const Gap(8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: iconColor,
              fontFamily: 'GeneralSans',
              letterSpacing: 16 * 0.02,
            ),
          ),
          const Gap(2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: iconColor.withOpacity(0.7),
              fontFamily: 'GeneralSans',
              letterSpacing: 10 * 0.02,
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/widgets/charts/arc_progress_indicator.dart';
// import '../../../../core/widgets/custom_card.dart';

// class SavingsTargetWidget extends StatelessWidget {
//   final String savingsInsight;

//   const SavingsTargetWidget({super.key, required this.savingsInsight});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width / 1.25,
//       child: CustomCard(
//         hasShadow: true,
//         padding: EdgeInsets.zero,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
//               child: const Text(
//                 'SAVINGS TARGET',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//             const Divider(height: 0),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   ArcProgressIndicator(
//                     progress: 0.7, // This should come from actual savings data
//                     color: AppColors.success,
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Gap(16),
//                         Text(
//                           '80%',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         Text(
//                           '₦160,000',
//                           style: TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         Text(
//                           'of ₦200,000',
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Gap(24.0),
//                   CustomElevatedButton(
//                     text: 'Get more insights',
//                     onPressed: () {},
//                     buttonColor: CustomButtonColor.black,
//                   ),
//                   const Gap(24.0),
//                   if (savingsInsight.isNotEmpty)
//                     InsightCard(
//                       text: savingsInsight,
//                       insightType: InsightType.nextBestAction,
//                       isExpandable: true,
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
