// lib/features/tools/presentation/screens/taxation/filing/filing_step4_screen.dart
//
// CHANGES vs previous version:
//   • walletBalance now sourced from filingWalletBalanceProvider
//     (set by Step 3 from payment/init response field "Wallet")
//   • Removed walletDashboardProvider dependency entirely
//   • All other logic unchanged

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/pin_bottom_sheet.dart';

const _planFees = <String, double>{
  'Basic PAYE': 7500,
  'Freelancer': 25000,
  'Freelance': 25000,
  'SME Lite': 75000,
  'Pro / Complex': 0,
  'Pro Complex': 0,
};

class FilingStep4Screen extends ConsumerStatefulWidget {
  static const String path = FilingRoutes.step4;
  const FilingStep4Screen({super.key});

  @override
  ConsumerState<FilingStep4Screen> createState() => _FilingStep4ScreenState();
}

class _FilingStep4ScreenState extends ConsumerState<FilingStep4Screen> {
  int _selectedPaymentIndex = 0;
  bool _isPaying = false;

  static const _yellow = Color(0xFFF5C842);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filingData = ref.read(filingHomeProvider).value;
      final process = filingData?.fillingProcess;
      if (process != null && ref.read(filingTaxDueProvider) == 0.0) {
        ref.read(filingTaxDueProvider.notifier).state =
            process.financeDetails.taxAmount;
        ref.read(selectedFilingPlanProvider.notifier).state = process.plan;
      }
    });
  }

  Future<void> _onPayFee(
      double filingFee, bool isCustomQuote, String filingId) async {
    if (_isPaying) return;

    print('Filing IDL: $filingId');

    final pin = await PinBottomSheet.show(
      context,
      title: 'Authorise filing fee payment',
      subtitle: isCustomQuote
          ? 'Enter your 4-digit PIN to request a custom quote.'
          : 'Enter your 4-digit PIN to pay the ₦${filingFee.formatCurrency(decimalDigits: 0).replaceAll('₦', '')} filing fee.',
      confirmLabel: isCustomQuote ? 'Request quote' : 'Pay now',
    );

    if (pin == null || !mounted) return;

    setState(() => _isPaying = true);
    try {
      final repo = ref.read(filingPaymentRepositoryProvider);
      await repo.payFillingFee(pin: pin, Id: filingId);

      if (mounted) {
        setState(() => _isPaying = false);
        AppNotification.show(
          context,
          message:
              'Filing fee received! 🎉 Your partner is now assigned to your return.',
          icon: Icons.celebration_outlined,
          iconColor: _yellow,
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) context.pushNamed(FilingRoutes.step5);
      }
    } catch (e) {
      setState(() => _isPaying = false);
      if (mounted) {
        AppNotification.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          icon: Icons.error_outline,
          iconColor: Colors.redAccent,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlan = ref.watch(selectedFilingPlanProvider);
    final taxDue = ref.watch(filingTaxDueProvider);
    final filingId = ref.watch(filingIDProvider);

    print('IDDD: $filingId'); 

    // Wallet balance written by Step 3 from payment/init response ("Wallet" field)
    final walletBalance = ref.watch(filingWalletBalanceProvider);

    final filingFee = _planFees[selectedPlan] ?? 0.0;
    final isCustomQuote =
        selectedPlan == 'Pro / Complex' || selectedPlan == 'Pro Complex';
    final walletSufficient = walletBalance >= filingFee;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Filing Fee'),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                children: [
                  const _StepBadge(label: 'STEP 4 OF 6 · FILING FEE'),
                  const Gap(16),
                  const Text(
                    'Two payments, clearly shown.',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 24 * 0.02,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    "There are two payments here — one to file, one to pay your taxes. Let's start with the filing fee so your partner can get to work.",
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 13,
                      color: AppColors.greyDark,
                      letterSpacing: 13 * 0.02,
                    ),
                  ),
                  const Gap(20),

                  Row(
                    children: [
                      Expanded(
                        child: _PaymentTypeCard(
                          label: 'FILING FEE',
                          amount: isCustomQuote
                              ? 'Custom'
                              : filingFee.formatCurrency(decimalDigits: 0),
                          subtitle: '$selectedPlan tier',
                          isActive: true,
                          actionLabel: 'Pay first',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PaymentTypeCard(
                          label: 'TAX LIABILITY',
                          amount: taxDue.formatCurrency(decimalDigits: 0),
                          subtitle: 'Paid to FIRS',
                          isActive: false,
                          actionLabel: 'Next step',
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),

                  // Wallet status row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Savvy Bee Wallet',
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 13 * 0.02,
                            ),
                          ),
                        ),
                        Text(
                          walletBalance.formatCurrency(decimalDigits: 0),
                          style: const TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 13 * 0.02,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: walletSufficient
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            walletSufficient ? '✓ Sufficient' : '✗ Insufficient',
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: walletSufficient
                                  ? const Color(0xFF43A047)
                                  : Colors.red.shade600,
                              letterSpacing: 10 * 0.02,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),

                  Text(
                    'Choose payment method for filing fee:',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 13,
                      color: AppColors.greyDark,
                      letterSpacing: 13 * 0.02,
                    ),
                  ),
                  const Gap(12),
                  _PaymentMethodTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Savvy Bee Wallet',
                    subtitle:
                        'Balance: ${walletBalance.formatCurrency(decimalDigits: 0)}',
                    isSelected: _selectedPaymentIndex == 0,
                    onTap: () => setState(() => _selectedPaymentIndex = 0),
                    disabled: false,
                  ),
                  const Gap(10),
                  _PaymentMethodTile(
                    icon: Icons.credit_card,
                    title: 'Debit/Credit Card',
                    subtitle: 'Visa •••• 4521',
                    isSelected: _selectedPaymentIndex == 1,
                    onTap: () => setState(() => _selectedPaymentIndex = 1),
                    disabled: true,
                  ),
                  const Gap(20),

                  // Fee summary
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _FeeRow(
                          label: 'Filing fee ($selectedPlan tier)',
                          value: isCustomQuote
                              ? 'Custom quote'
                              : filingFee.formatCurrency(decimalDigits: 0),
                        ),
                        const Gap(8),
                        const _FeeRow(
                          label: 'Processing fee',
                          value: 'Free',
                          valueColor: Color(0xFF43A047),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: AppColors.borderLight),
                        ),
                        _FeeRow(
                          label: 'Total today',
                          value: isCustomQuote
                              ? 'Custom quote'
                              : filingFee.formatCurrency(decimalDigits: 0),
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Your tax liability of ${taxDue.formatCurrency(decimalDigits: 0)} will be paid in the next step',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 11,
                      color: AppColors.greyDark,
                      letterSpacing: 11 * 0.02,
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ),
            BottomActionButton(
              label: _isPaying
                  ? 'Processing…'
                  : isCustomQuote
                  ? 'Request custom quote'
                  : 'Pay filing fee — ${filingFee.formatCurrency(decimalDigits: 0)}',
              onTap: _isPaying
                  ? null
                  : () => _onPayFee(filingFee, isCustomQuote, filingId),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _PaymentTypeCard extends StatelessWidget {
  final String label, amount, subtitle, actionLabel;
  final bool isActive;
  const _PaymentTypeCard({
    required this.label,
    required this.amount,
    required this.subtitle,
    required this.isActive,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isActive ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isActive ? const Color(0xFFF5C842) : AppColors.borderLight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFFF5C842) : AppColors.greyDark,
            letterSpacing: 10 * 0.02,
          ),
        ),
        const Gap(4),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : Colors.black87,
            letterSpacing: 18 * 0.02,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 11,
            color: isActive ? Colors.white60 : AppColors.greyDark,
            letterSpacing: 11 * 0.02,
          ),
        ),
        const Gap(10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFF5C842).withOpacity(0.3)
                : const Color(0xFF8eaaff).withOpacity(0.3),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            actionLabel,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? const Color(0xFFF5C842)
                  : const Color(0xFF8eaaff),
              letterSpacing: 11 * 0.02,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool disabled;
  static const _yellow = Color(0xFFF5C842);
  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: disabled ? null : onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? _yellow : AppColors.borderLight,
          width: isSelected ? 1.8 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: disabled
            ? Colors.grey[200]
            : isSelected
            ? _yellow.withValues(alpha: 0.05)
            : Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 13 * 0.02,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 11,
                    color: AppColors.greyDark,
                    letterSpacing: 11 * 0.02,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? _yellow : AppColors.grey,
                width: 2,
              ),
              color: isSelected ? _yellow : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 12, color: Colors.black)
                : null,
          ),
        ],
      ),
    ),
  );
}

class _FeeRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;
  const _FeeRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 13,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          letterSpacing: 13 * 0.02,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 13,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          color: valueColor ?? Colors.black87,
          letterSpacing: 13 * 0.02,
        ),
      ),
    ],
  );
}

class _StepBadge extends StatelessWidget {
  final String label;
  const _StepBadge({required this.label});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFFF5C842),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: 11 * 0.02,
        ),
      ),
    ],
  );
}



// // lib/features/tools/presentation/screens/taxation/filing/filing_step4_screen.dart
// //
// // CHANGES vs previous version:
// //   • _onPayFee() shows PIN bottom sheet → calls payment/fillingfee API
// //   • Errors shown via AppNotification
// //   • Keyboard dismiss via GestureDetector
// //   • Resume-from-API: filingData.fillingProcess.financeDetails seeds taxDue if needed

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
// import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/pin_bottom_sheet.dart';

// const _planFees = <String, double>{
//   'Basic PAYE': 7500,
//   'Freelancer': 25000,
//   'Freelance': 25000,
//   'SME Lite': 75000,
//   'Pro / Complex': 0,
//   'Pro Complex': 0,
// };

// class FilingStep4Screen extends ConsumerStatefulWidget {
//   static const String path = FilingRoutes.step4;
//   const FilingStep4Screen({super.key});

//   @override
//   ConsumerState<FilingStep4Screen> createState() => _FilingStep4ScreenState();
// }

// class _FilingStep4ScreenState extends ConsumerState<FilingStep4Screen> {
//   int _selectedPaymentIndex = 0;
//   bool _isPaying = false;

//   static const _yellow = Color(0xFFF5C842);

//   @override
//   void initState() {
//     super.initState();
//     // If we arrived here via resume routing, seed taxDue from the process
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final filingData = ref.read(filingHomeProvider).value;
//       final process = filingData?.fillingProcess;
//       if (process != null && ref.read(filingTaxDueProvider) == 0.0) {
//         ref.read(filingTaxDueProvider.notifier).state =
//             process.financeDetails.taxAmount;
//         ref.read(selectedFilingPlanProvider.notifier).state = process.plan;
//       }
//     });
//   }

//   Future<void> _onPayFee(double filingFee, bool isCustomQuote, String filingId) async {
//     if (_isPaying) return;

//     final pin = await PinBottomSheet.show(
//       context,
//       title: 'Authorise filing fee payment',
//       subtitle: isCustomQuote
//           ? 'Enter your 4-digit PIN to request a custom quote.'
//           : 'Enter your 4-digit PIN to pay the ₦${filingFee.formatCurrency(decimalDigits: 0).replaceAll('₦', '')} filing fee.',
//       confirmLabel: isCustomQuote ? 'Request quote' : 'Pay now',
//     );

//     if (pin == null || !mounted) return;

//     setState(() => _isPaying = true);
//     try {
//       final repo = ref.read(filingPaymentRepositoryProvider);
//       await repo.payFillingFee(pin: pin, Id: filingId);

//       if (mounted) {
//         setState(() => _isPaying = false); 
//         AppNotification.show(
//           context,
//           message:
//               'Filing fee received! 🎉 Your partner is now assigned to your return.',
//           icon: Icons.celebration_outlined,
//           iconColor: _yellow,
//         );
//         await Future.delayed(const Duration(milliseconds: 800));
//         if (mounted) context.pushNamed(FilingRoutes.step5);
//       }
//     } catch (e) {
//       setState(() => _isPaying = false);
//       if (mounted) {
//         AppNotification.show(
//           context,
//           message: 'Payment failed: ${e.toString()}',
//           icon: Icons.error_outline,
//           iconColor: Colors.redAccent,
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selectedPlan = ref.watch(selectedFilingPlanProvider);
//     final taxDue = ref.watch(filingTaxDueProvider);
//     final filingId = ref.watch(filingIDProvider);
//     final filingData = ref.watch(filingHomeProvider).value;

//     final filingFee = _planFees[selectedPlan] ?? 0.0;
//     final isCustomQuote =
//         selectedPlan == 'Pro / Complex' || selectedPlan == 'Pro Complex';
//     final walletBalance = filingData?.taxPot ?? 0.0;
//     final walletSufficient = walletBalance >= filingFee;

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         appBar: AppBar(
//           leading: const BackButton(),
//           title: const Text('Filing Fee'),
//           centerTitle: false,
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//                 children: [
//                   const _StepBadge(label: 'STEP 4 OF 6 · FILING FEE'),
//                   const Gap(16),
//                   const Text(
//                     'Two payments, clearly shown.',
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 24 * 0.02,
//                     ),
//                   ),
//                   const Gap(8),
//                   Text(
//                     "There are two payments here — one to file, one to pay your taxes. Let's start with the filing fee so your partner can get to work.",
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 13,
//                       color: AppColors.greyDark,
//                       letterSpacing: 13 * 0.02,
//                     ),
//                   ),
//                   const Gap(20),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: _PaymentTypeCard(
//                           label: 'FILING FEE',
//                           amount: isCustomQuote
//                               ? 'Custom'
//                               : filingFee.formatCurrency(decimalDigits: 0),
//                           subtitle: '$selectedPlan tier',
//                           isActive: true,
//                           actionLabel: 'Pay first',
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: _PaymentTypeCard(
//                           label: 'TAX LIABILITY',
//                           amount: taxDue.formatCurrency(decimalDigits: 0),
//                           subtitle: 'Paid to FIRS',
//                           isActive: false,
//                           actionLabel: 'Next step',
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Gap(20),

//                   // Wallet status
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 12,
//                       horizontal: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.greyLight,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.account_balance_wallet,
//                             size: 18,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         const Expanded(
//                           child: Text(
//                             'Savvy Bee Wallet',
//                             style: TextStyle(
//                               fontFamily: 'GeneralSans',
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                               letterSpacing: 13 * 0.02,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           walletBalance.formatCurrency(decimalDigits: 0),
//                           style: const TextStyle(
//                             fontFamily: 'GeneralSans',
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             letterSpacing: 13 * 0.02,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 3,
//                             horizontal: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: walletSufficient
//                                 ? const Color(0xFFE8F5E9)
//                                 : const Color(0xFFFFEBEE),
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           child: Text(
//                             walletSufficient
//                                 ? '✓ Sufficient'
//                                 : '✗ Insufficient',
//                             style: TextStyle(
//                               fontFamily: 'GeneralSans',
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                               color: walletSufficient
//                                   ? const Color(0xFF43A047)
//                                   : Colors.red.shade600,
//                               letterSpacing: 10 * 0.02,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Gap(20),

//                   Text(
//                     'Choose payment method for filing fee:',
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 13,
//                       color: AppColors.greyDark,
//                       letterSpacing: 13 * 0.02,
//                     ),
//                   ),
//                   const Gap(12),
//                   _PaymentMethodTile(
//                     icon: Icons.account_balance_wallet_outlined,
//                     title: 'Savvy Bee Wallet',
//                     subtitle:
//                         'Balance: ${walletBalance.formatCurrency(decimalDigits: 0)}',
//                     isSelected: _selectedPaymentIndex == 0,
//                     onTap: () => setState(() => _selectedPaymentIndex = 0),
//                     disabled: false,
//                   ),
//                   const Gap(10),
//                   _PaymentMethodTile(
//                     icon: Icons.credit_card,
//                     title: 'Debit/Credit Card',
//                     subtitle: 'Visa •••• 4521',
//                     isSelected: _selectedPaymentIndex == 1,
//                     onTap: () => setState(() => _selectedPaymentIndex = 1),
//                     disabled: true, // Card payment not implemented yet
//                   ),
//                   const Gap(20),

//                   // Fee summary
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: AppColors.borderLight),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       children: [
//                         _FeeRow(
//                           label: 'Filing fee ($selectedPlan tier)',
//                           value: isCustomQuote
//                               ? 'Custom quote'
//                               : filingFee.formatCurrency(decimalDigits: 0),
//                         ),
//                         const Gap(8),
//                         const _FeeRow(
//                           label: 'Processing fee',
//                           value: 'Free',
//                           valueColor: Color(0xFF43A047),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           child: Divider(color: AppColors.borderLight),
//                         ),
//                         _FeeRow(
//                           label: 'Total today',
//                           value: isCustomQuote
//                               ? 'Custom quote'
//                               : filingFee.formatCurrency(decimalDigits: 0),
//                           isBold: true,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Gap(8),
//                   Text(
//                     'Your tax liability of ${taxDue.formatCurrency(decimalDigits: 0)} will be paid in the next step',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 11,
//                       color: AppColors.greyDark,
//                       letterSpacing: 11 * 0.02,
//                     ),
//                   ),
//                   const Gap(24),
//                 ],
//               ),
//             ),
//             BottomActionButton(
//               label: _isPaying
//                   ? 'Processing…'
//                   : isCustomQuote
//                   ? 'Request custom quote'
//                   : 'Pay filing fee — ${filingFee.formatCurrency(decimalDigits: 0)}',
//               onTap: _isPaying
//                   ? null
//                   : () => _onPayFee(filingFee, isCustomQuote, filingId),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Widgets (unchanged UI) ────────────────────────────────────────────────────

// class _PaymentTypeCard extends StatelessWidget {
//   final String label, amount, subtitle, actionLabel;
//   final bool isActive;
//   const _PaymentTypeCard({
//     required this.label,
//     required this.amount,
//     required this.subtitle,
//     required this.isActive,
//     required this.actionLabel,
//   });

//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: isActive ? const Color(0xFF1A1A1A) : Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(
//         color: isActive ? const Color(0xFFF5C842) : AppColors.borderLight,
//       ),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontFamily: 'GeneralSans',
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//             color: isActive ? const Color(0xFFF5C842) : AppColors.greyDark,
//             letterSpacing: 10 * 0.02,
//           ),
//         ),
//         const Gap(4),
//         Text(
//           amount,
//           style: TextStyle(
//             fontFamily: 'GeneralSans',
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: isActive ? Colors.white : Colors.black87,
//             letterSpacing: 18 * 0.02,
//           ),
//         ),
//         Text(
//           subtitle,
//           style: TextStyle(
//             fontFamily: 'GeneralSans',
//             fontSize: 11,
//             color: isActive ? Colors.white60 : AppColors.greyDark,
//             letterSpacing: 11 * 0.02,
//           ),
//         ),
//         const Gap(10),
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//           decoration: BoxDecoration(
//             color: isActive
//                 ? const Color(0xFFF5C842).withOpacity(0.3)
//                 : const Color(0xFF8eaaff).withOpacity(0.3),
//             borderRadius: BorderRadius.circular(50),
//           ),
//           child: Text(
//             actionLabel,
//             style: TextStyle(
//               fontFamily: 'GeneralSans',
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: isActive
//                   ? const Color(0xFFF5C842)
//                   : const Color(0xFF8eaaff),
//               letterSpacing: 11 * 0.02,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class _PaymentMethodTile extends StatelessWidget {
//   final IconData icon;
//   final String title, subtitle;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final bool disabled;
//   static const _yellow = Color(0xFFF5C842);
//   const _PaymentMethodTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.isSelected,
//     required this.onTap,
//     required this.disabled
//   });

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: disabled ? null : onTap,
//     child: Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: isSelected ? _yellow : AppColors.borderLight,
//           width: isSelected ? 1.8 : 1,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         color: disabled ? Colors.grey[200] : isSelected ? _yellow.withValues(alpha: 0.05) : Colors.white,
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.black87),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: 13 * 0.02,
//                   ),
//                 ),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontSize: 11,
//                     color: AppColors.greyDark,
//                     letterSpacing: 11 * 0.02,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 20,
//             height: 20,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: isSelected ? _yellow : AppColors.grey,
//                 width: 2,
//               ),
//               color: isSelected ? _yellow : Colors.transparent,
//             ),
//             child: isSelected
//                 ? const Icon(Icons.check, size: 12, color: Colors.black)
//                 : null,
//           ),
//         ],
//       ),
//     ),
//   );
// }

// class _FeeRow extends StatelessWidget {
//   final String label, value;
//   final bool isBold;
//   final Color? valueColor;
//   const _FeeRow({
//     required this.label,
//     required this.value,
//     this.isBold = false,
//     this.valueColor,
//   });

//   @override
//   Widget build(BuildContext context) => Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         label,
//         style: TextStyle(
//           fontFamily: 'GeneralSans',
//           fontSize: 13,
//           fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
//           letterSpacing: 13 * 0.02,
//         ),
//       ),
//       Text(
//         value,
//         style: TextStyle(
//           fontFamily: 'GeneralSans',
//           fontSize: 13,
//           fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
//           color: valueColor ?? Colors.black87,
//           letterSpacing: 13 * 0.02,
//         ),
//       ),
//     ],
//   );
// }

// class _StepBadge extends StatelessWidget {
//   final String label;
//   const _StepBadge({required this.label});
//   @override
//   Widget build(BuildContext context) => Row(
//     children: [
//       Container(
//         width: 8,
//         height: 8,
//         decoration: const BoxDecoration(
//           color: Color(0xFFF5C842),
//           shape: BoxShape.circle,
//         ),
//       ),
//       const SizedBox(width: 6),
//       Text(
//         label,
//         style: const TextStyle(
//           fontFamily: 'GeneralSans',
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//           letterSpacing: 11 * 0.02,
//         ),
//       ),
//     ],
//   );
// }
