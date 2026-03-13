// lib/features/tools/presentation/screens/taxation/filing/filing_step5_screen.dart
//
// CHANGES vs previous version:
//   • Savvy Bee Wallet tile subtitle now uses filingWalletBalanceProvider
//     (written by Step 3 from payment/init response "Wallet" field)
//   • taxPot from filingHomeData still drives Tax Pot coverage logic (unchanged)
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

class FilingStep5Screen extends ConsumerStatefulWidget {
  static const String path = FilingRoutes.step5;
  const FilingStep5Screen({super.key});

  @override
  ConsumerState<FilingStep5Screen> createState() => _FilingStep5ScreenState();
}

class _FilingStep5ScreenState extends ConsumerState<FilingStep5Screen> {
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

  Future<void> _onConfirmPayment(double taxDue, String filingId) async {
    if (_isPaying) return;

    final pin = await PinBottomSheet.show(
      context,
      title: 'Authorise tax payment',
      subtitle:
          'Enter your 4-digit PIN to pay your ${taxDue.formatCurrency(decimalDigits: 0)} tax liability.',
      confirmLabel: 'Pay tax now',
    );

    if (pin == null || !mounted) return;

    setState(() => _isPaying = true);
    try {
      final repo = ref.read(filingPaymentRepositoryProvider);
      final result = await repo.payLiabilityFee(pin: pin, Id: filingId);

      ref.read(filingLiabilityResultProvider.notifier).state = result;

      if (mounted) {
        setState(() => _isPaying = false);
        AppNotification.show(
          context,
          message:
              'Payment confirmed! ✓ Your return is now ready for submission.',
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF43A047),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) context.pushNamed(FilingRoutes.step6);
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
    final taxDue = ref.watch(filingTaxDueProvider);
    final filingData = ref.watch(filingHomeProvider).value;
    final filingId = ref.watch(filingIDProvider);

    // Tax Pot (savings pot) — drives coverage logic
    final taxPot = filingData?.taxPot ?? 0.0;
    final taxPotCovers = taxPot >= taxDue;
    final remainder = taxPot - taxDue;

    // Wallet balance from payment/init response — shown in the Savvy Bee Wallet tile
    final walletBalance = ref.watch(filingWalletBalanceProvider);

    final taxYear = DateTime.now().year - 1;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Tax Payment'),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                children: [
                  const _StepBadge(label: 'STEP 5 OF 6 · TAX PAYMENT'),
                  const Gap(16),
                  const Text(
                    'Now for your taxes.',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 24 * 0.02,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    'Filing fee cleared. Time to settle your $taxYear tax liability.',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 13,
                      color: AppColors.greyDark,
                      letterSpacing: 13 * 0.02,
                    ),
                  ),
                  const Gap(20),

                  // Dark liability card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$taxYear Tax Liability',
                          style: const TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 12,
                            color: Colors.white60,
                            letterSpacing: 12 * 0.02,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          taxDue.formatCurrency(decimalDigits: 0),
                          style: const TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 32 * 0.02,
                          ),
                        ),
                        const Gap(10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: taxPotCovers
                                ? const Color(0xFF43A047).withValues(alpha: 0.2)
                                : Colors.redAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 6,
                            children: [
                              Icon(
                                taxPotCovers
                                    ? Icons.check_circle
                                    : Icons.warning_amber_rounded,
                                size: 14,
                                color: taxPotCovers
                                    ? const Color(0xFF43A047)
                                    : Colors.redAccent,
                              ),
                              Text(
                                taxPotCovers
                                    ? "Tax Pot: ${taxPot.formatCurrency(decimalDigits: 0)} — You're covered"
                                    : "Tax Pot: ${taxPot.formatCurrency(decimalDigits: 0)} — Shortfall: ${(taxDue - taxPot).formatCurrency(decimalDigits: 0)}",
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: taxPotCovers
                                      ? const Color(0xFF81C784)
                                      : Colors.redAccent.shade100,
                                  letterSpacing: 11 * 0.02,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: taxPotCovers
                          ? const Color(0xFFF0FFF4)
                          : const Color(0xFFFFF8F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: taxPotCovers
                            ? const Color(0xFF43A047).withValues(alpha: 0.3)
                            : Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: taxPotCovers
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.savings_outlined,
                            size: 18,
                            color: taxPotCovers
                                ? const Color(0xFF43A047)
                                : Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Tax Pot has ${taxPot.formatCurrency(decimalDigits: 0)} saved.",
                                style: const TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 13 * 0.02,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                taxPotCovers
                                    ? "You saved exactly for this. Pay directly from your Tax Pot — you're fully covered with ${remainder.formatCurrency(decimalDigits: 0)} to spare."
                                    : "Your Tax Pot covers part of your liability. You'll need to top up ${(taxDue - taxPot).formatCurrency(decimalDigits: 0)} via another method.",
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontSize: 12,
                                  color: AppColors.greyDark,
                                  letterSpacing: 12 * 0.02,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),

                  // Breakdown
                  const Text(
                    'Breakdown',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 14 * 0.02,
                    ),
                  ),
                  const Gap(12),
                  _BreakdownRow(
                    label: 'Tax payable',
                    value: taxDue.formatCurrency(decimalDigits: 0),
                  ),
                  _BreakdownRow(
                    label: 'Tax Pot balance',
                    value: taxPot.formatCurrency(decimalDigits: 0),
                  ),
                  _BreakdownRow(
                    label: taxPotCovers
                        ? 'Remaining after payment'
                        : 'Shortfall',
                    value: remainder.abs().formatCurrency(decimalDigits: 0),
                    valueColor: taxPotCovers
                        ? const Color(0xFF43A047)
                        : Colors.redAccent,
                  ),
                  const Gap(20),

                  // Payment methods
                  const Text(
                    'Payment method',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 14 * 0.02,
                    ),
                  ),
                  const Gap(12),
                  _PaymentMethodTile(
                    icon: Icons.savings_outlined,
                    title: 'Pay from Tax Pot',
                    subtitle:
                        'Balance: ${taxPot.formatCurrency(decimalDigits: 0)}${taxPotCovers ? " — you're fully covered" : ' — partial coverage'}',
                    badge: 'Recommended',
                    isSelected: _selectedPaymentIndex == 0,
                    isDisabled: taxPot <= 0,
                    onTap: () => setState(() => _selectedPaymentIndex = 0),
                  ),
                  const Gap(10),
                  _PaymentMethodTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Savvy Bee Wallet',
                    // Live balance from payment/init response
                    subtitle:
                        'Balance: ${walletBalance.formatCurrency(decimalDigits: 0)}',
                    isSelected: _selectedPaymentIndex == 1,
                    isDisabled: false,
                    onTap: () => setState(() => _selectedPaymentIndex = 1),
                  ),
                  const Gap(10),
                  _PaymentMethodTile(
                    icon: Icons.account_balance_outlined,
                    title: 'Bank Transfer to NRS',
                    subtitle: 'Account details pre-filled',
                    isSelected: _selectedPaymentIndex == 2,
                    isDisabled: true,
                    onTap: () => setState(() => _selectedPaymentIndex = 2),
                  ),
                  const Gap(16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _yellow.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _yellow.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bolt, size: 16, color: _yellow),
                        Expanded(
                          child: Text(
                            'Coming soon: Savvy Bee will pay your taxes directly on your behalf, automatically on the due date.',
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: 11,
                              color: AppColors.greyDark,
                              letterSpacing: 11 * 0.02,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ),
            BottomActionButton(
              label: _isPaying
                  ? 'Processing…'
                  : 'Confirm tax payment — ${taxDue.formatCurrency(decimalDigits: 0)}',
              onTap: _isPaying
                  ? null
                  : () => _onConfirmPayment(taxDue, filingId),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _BreakdownRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 13,
            color: AppColors.greyDark,
            letterSpacing: 13 * 0.02,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
            letterSpacing: 13 * 0.02,
          ),
        ),
      ],
    ),
  );
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final String? badge;
  final bool isSelected, isDisabled;
  final VoidCallback onTap;
  static const _yellow = Color(0xFFF5C842);
  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: isDisabled ? null : onTap,
    child: Opacity(
      opacity: isDisabled ? 0.45 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? _yellow : AppColors.borderLight,
            width: isSelected ? 1.8 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? _yellow.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 6,
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
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _yellow,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: 9 * 0.02,
                            ),
                          ),
                        ),
                    ],
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
    ),
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



// // lib/features/tools/presentation/screens/taxation/filing/filing_step5_screen.dart
// //
// // CHANGES vs previous version:
// //   • _onConfirmPayment() shows PIN sheet → calls payment/liabilityfee API
// //   • LiabilityFeeResult stored in filingLiabilityResultProvider for Step 6
// //   • Resume-from-API: seeds taxDue from fillingProcess if provider is 0
// //   • Errors via AppNotification; keyboard dismiss via GestureDetector

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

// class FilingStep5Screen extends ConsumerStatefulWidget {
//   static const String path = FilingRoutes.step5;
//   const FilingStep5Screen({super.key});

//   @override
//   ConsumerState<FilingStep5Screen> createState() => _FilingStep5ScreenState();
// }

// class _FilingStep5ScreenState extends ConsumerState<FilingStep5Screen> {
//   int _selectedPaymentIndex = 0;
//   bool _isPaying = false;

//   static const _yellow = Color(0xFFF5C842);

//   @override
//   void initState() {
//     super.initState();
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

//   Future<void> _onConfirmPayment(double taxDue, String filingId) async {
//     if (_isPaying) return;

//     final pin = await PinBottomSheet.show(
//       context,
//       title: 'Authorise tax payment',
//       subtitle:
//           'Enter your 4-digit PIN to pay your ${taxDue.formatCurrency(decimalDigits: 0)} tax liability.',
//       confirmLabel: 'Pay tax now',
//     );

//     if (pin == null || !mounted) return;

//     setState(() => _isPaying = true);
//     try {
//       final repo = ref.read(filingPaymentRepositoryProvider);
//       final result = await repo.payLiabilityFee(pin: pin, Id: filingId);

//       // Store for Step 6
//       ref.read(filingLiabilityResultProvider.notifier).state = result;

//       if (mounted) {
//         setState(() => _isPaying = false);
//         AppNotification.show(
//           context,
//           message:
//               'Payment confirmed! ✓ Your return is now ready for submission.',
//           icon: Icons.check_circle_outline,
//           iconColor: const Color(0xFF43A047),
//         );
//         await Future.delayed(const Duration(milliseconds: 800));
//         if (mounted) context.pushNamed(FilingRoutes.step6);
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
//     final taxDue = ref.watch(filingTaxDueProvider);
//     final filingData = ref.watch(filingHomeProvider).value;
//     final filingId = ref.watch(filingIDProvider);
//     final taxPot = filingData?.taxPot ?? 0.0;
//     final taxPotCovers = taxPot >= taxDue;
//     final remainder = taxPot - taxDue;
//     final taxYear = DateTime.now().year - 1;

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         appBar: AppBar(
//           leading: const BackButton(),
//           title: const Text('Tax Payment'),
//           centerTitle: false,
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//                 children: [
//                   const _StepBadge(label: 'STEP 5 OF 6 · TAX PAYMENT'),
//                   const Gap(16),
//                   const Text(
//                     'Now for your taxes.',
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 24 * 0.02,
//                     ),
//                   ),
//                   const Gap(6),
//                   Text(
//                     'Filing fee cleared. Time to settle your $taxYear tax liability.',
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 13,
//                       color: AppColors.greyDark,
//                       letterSpacing: 13 * 0.02,
//                     ),
//                   ),
//                   const Gap(20),

//                   // Dark liability card
//                   Container(
//                     padding: const EdgeInsets.all(18),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1A1A1A),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '$taxYear Tax Liability',
//                           style: const TextStyle(
//                             fontFamily: 'GeneralSans',
//                             fontSize: 12,
//                             color: Colors.white60,
//                             letterSpacing: 12 * 0.02,
//                           ),
//                         ),
//                         const Gap(4),
//                         Text(
//                           taxDue.formatCurrency(decimalDigits: 0),
//                           style: const TextStyle(
//                             fontFamily: 'GeneralSans',
//                             fontSize: 32,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                             letterSpacing: 32 * 0.02,
//                           ),
//                         ),
//                         const Gap(10),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 6,
//                             horizontal: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             color: taxPotCovers
//                                 ? const Color(0xFF43A047).withValues(alpha: 0.2)
//                                 : Colors.redAccent.withValues(alpha: 0.2),
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             spacing: 6,
//                             children: [
//                               Icon(
//                                 taxPotCovers
//                                     ? Icons.check_circle
//                                     : Icons.warning_amber_rounded,
//                                 size: 14,
//                                 color: taxPotCovers
//                                     ? const Color(0xFF43A047)
//                                     : Colors.redAccent,
//                               ),
//                               Text(
//                                 taxPotCovers
//                                     ? "Tax Pot: ${taxPot.formatCurrency(decimalDigits: 0)} — You're covered"
//                                     : "Tax Pot: ${taxPot.formatCurrency(decimalDigits: 0)} — Shortfall: ${(taxDue - taxPot).formatCurrency(decimalDigits: 0)}",
//                                 style: TextStyle(
//                                   fontFamily: 'GeneralSans',
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w500,
//                                   color: taxPotCovers
//                                       ? const Color(0xFF81C784)
//                                       : Colors.redAccent.shade100,
//                                   letterSpacing: 11 * 0.02,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Gap(16),

//                   // Info card
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: taxPotCovers
//                           ? const Color(0xFFF0FFF4)
//                           : const Color(0xFFFFF8F0),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: taxPotCovers
//                             ? const Color(0xFF43A047).withValues(alpha: 0.3)
//                             : Colors.orange.withValues(alpha: 0.3),
//                       ),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       spacing: 10,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: taxPotCovers
//                                 ? const Color(0xFFE8F5E9)
//                                 : const Color(0xFFFFF3E0),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(
//                             Icons.savings_outlined,
//                             size: 18,
//                             color: taxPotCovers
//                                 ? const Color(0xFF43A047)
//                                 : Colors.orange,
//                           ),
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Your Tax Pot has ${taxPot.formatCurrency(decimalDigits: 0)} saved.",
//                                 style: const TextStyle(
//                                   fontFamily: 'GeneralSans',
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600,
//                                   letterSpacing: 13 * 0.02,
//                                 ),
//                               ),
//                               const Gap(4),
//                               Text(
//                                 taxPotCovers
//                                     ? "You saved exactly for this. Pay directly from your Tax Pot — you're fully covered with ${remainder.formatCurrency(decimalDigits: 0)} to spare."
//                                     : "Your Tax Pot covers part of your liability. You'll need to top up ${(taxDue - taxPot).formatCurrency(decimalDigits: 0)} via another method.",
//                                 style: TextStyle(
//                                   fontFamily: 'GeneralSans',
//                                   fontSize: 12,
//                                   color: AppColors.greyDark,
//                                   letterSpacing: 12 * 0.02,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Gap(20),

//                   // Breakdown
//                   const Text(
//                     'Breakdown',
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 14 * 0.02,
//                     ),
//                   ),
//                   const Gap(12),
//                   _BreakdownRow(
//                     label: 'Tax payable',
//                     value: taxDue.formatCurrency(decimalDigits: 0),
//                   ),
//                   _BreakdownRow(
//                     label: 'Tax Pot balance',
//                     value: taxPot.formatCurrency(decimalDigits: 0),
//                   ),
//                   _BreakdownRow(
//                     label: taxPotCovers
//                         ? 'Remaining after payment'
//                         : 'Shortfall',
//                     value: remainder.abs().formatCurrency(decimalDigits: 0),
//                     valueColor: taxPotCovers
//                         ? const Color(0xFF43A047)
//                         : Colors.redAccent,
//                   ),
//                   const Gap(20),

//                   // Payment methods
//                   const Text(
//                     'Payment method',
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 14 * 0.02,
//                     ),
//                   ),
//                   const Gap(12),
//                   _PaymentMethodTile(
//                     icon: Icons.savings_outlined,
//                     title: 'Pay from Tax Pot',
//                     subtitle:
//                         'Balance: ${taxPot.formatCurrency(decimalDigits: 0)}${taxPotCovers ? " — you're fully covered" : ' — partial coverage'}',
//                     badge: 'Recommended',
//                     isSelected: _selectedPaymentIndex == 0,
//                     isDisabled: taxPot <= 0,
//                     onTap: () => setState(() => _selectedPaymentIndex = 0),
//                   ),
//                   const Gap(10),
//                   _PaymentMethodTile(
//                     icon: Icons.account_balance_wallet_outlined,
//                     title: 'Savvy Bee Wallet',
//                     subtitle: filingData != null
//                         ? 'Balance: ${filingData.taxPot.formatCurrency(decimalDigits: 0)}'
//                         : 'Loading...',
//                     isSelected: _selectedPaymentIndex == 1,
//                     isDisabled: false,
//                     onTap: () => setState(() => _selectedPaymentIndex = 1),
//                   ),
//                   const Gap(10),
//                   _PaymentMethodTile(
//                     icon: Icons.account_balance_outlined,
//                     title: 'Bank Transfer to NRS',
//                     subtitle: 'Account details pre-filled',
//                     isSelected: _selectedPaymentIndex == 2,
//                     isDisabled: true,
//                     onTap: () => setState(() => _selectedPaymentIndex = 2),
//                   ),
//                   const Gap(16), 

//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: _yellow.withValues(alpha: 0.08),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: _yellow.withValues(alpha: 0.3)),
//                     ),
//                     child: Row(
//                       spacing: 8,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Icon(Icons.bolt, size: 16, color: _yellow),
//                         Expanded(
//                           child: Text(
//                             'Coming soon: Savvy Bee will pay your taxes directly on your behalf, automatically on the due date.',
//                             style: TextStyle(
//                               fontFamily: 'GeneralSans',
//                               fontSize: 11,
//                               color: AppColors.greyDark,
//                               letterSpacing: 11 * 0.02,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Gap(24),
//                 ],
//               ),
//             ),
//             BottomActionButton(
//               label: _isPaying
//                   ? 'Processing…'
//                   : 'Confirm tax payment — ${taxDue.formatCurrency(decimalDigits: 0)}',
//               onTap: _isPaying ? null : () => _onConfirmPayment(taxDue, filingId),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Widgets ───────────────────────────────────────────────────────────────────

// class _BreakdownRow extends StatelessWidget {
//   final String label, value;
//   final Color? valueColor;
//   const _BreakdownRow({
//     required this.label,
//     required this.value,
//     this.valueColor,
//   });

//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontFamily: 'GeneralSans',
//             fontSize: 13,
//             color: AppColors.greyDark,
//             letterSpacing: 13 * 0.02,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontFamily: 'GeneralSans',
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: valueColor ?? Colors.black87,
//             letterSpacing: 13 * 0.02,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class _PaymentMethodTile extends StatelessWidget {
//   final IconData icon;
//   final String title, subtitle;
//   final String? badge;
//   final bool isSelected, isDisabled;
//   final VoidCallback onTap;
//   static const _yellow = Color(0xFFF5C842);
//   const _PaymentMethodTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     this.badge,
//     required this.isSelected,
//     required this.isDisabled,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: isDisabled ? null : onTap,
//     child: Opacity(
//       opacity: isDisabled ? 0.45 : 1.0,
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected ? _yellow : AppColors.borderLight,
//             width: isSelected ? 1.8 : 1,
//           ),
//           borderRadius: BorderRadius.circular(12),
//           color: isSelected ? _yellow.withValues(alpha: 0.05) : Colors.white,
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 20, color: Colors.black87),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     spacing: 6,
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           letterSpacing: 13 * 0.02,
//                         ),
//                       ),
//                       if (badge != null)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 2,
//                             horizontal: 7,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _yellow,
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           child: Text(
//                             badge!,
//                             style: const TextStyle(
//                               fontFamily: 'GeneralSans',
//                               fontSize: 9,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.black,
//                               letterSpacing: 9 * 0.02,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 11,
//                       color: AppColors.greyDark,
//                       letterSpacing: 11 * 0.02,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isSelected ? _yellow : AppColors.grey,
//                   width: 2,
//                 ),
//                 color: isSelected ? _yellow : Colors.transparent,
//               ),
//               child: isSelected
//                   ? const Icon(Icons.check, size: 12, color: Colors.black)
//                   : null,
//             ),
//           ],
//         ),
//       ),
//     ),
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