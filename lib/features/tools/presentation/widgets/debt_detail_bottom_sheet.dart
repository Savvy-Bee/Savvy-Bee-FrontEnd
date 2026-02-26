import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/debt.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/debt_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Progress colour  0-25% → red  |  26-75% → yellow  |  76-100% → green
// ─────────────────────────────────────────────────────────────────────────────

Color _progressColor(double progress) {
  final pct = (progress * 100).clamp(0, 100);
  if (pct <= 25) return AppColors.error;
  if (pct <= 75) return const Color(0xFFFFC300);
  return AppColors.success;
}

// ─────────────────────────────────────────────────────────────────────────────
// Public entry-point
// ─────────────────────────────────────────────────────────────────────────────

class DebtDetailBottomSheet {
  static Future<void> show(BuildContext context, Debt debt) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Lets the sheet resize when the keyboard appears
      builder: (_) => DebtDetailBottomSheetContent(debt: debt),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet content widget
// ─────────────────────────────────────────────────────────────────────────────

class DebtDetailBottomSheetContent extends ConsumerStatefulWidget {
  const DebtDetailBottomSheetContent({super.key, required this.debt});

  final Debt debt;

  @override
  ConsumerState<DebtDetailBottomSheetContent> createState() =>
      _DebtDetailBottomSheetContentState();
}

class _DebtDetailBottomSheetContentState
    extends ConsumerState<DebtDetailBottomSheetContent> {
  final _amountController = TextEditingController();
  final _formKey           = GlobalKey<FormState>();
  final _scrollController  = ScrollController();
  bool _isSubmitting       = false;

  @override
  void dispose() {
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Submit repayment ──────────────────────────────────────────────────────

  Future<void> _submitRepayment() async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss keyboard first so the sheet doesn't jump
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      await ref.read(debtListNotifierProvider.notifier).manualFundDebt(
            widget.debt.id,
            _amountController.text.trim(),
          );

      if (mounted) {
        CustomSnackbar.show(
          context,
          'Repayment recorded successfully',
          type: SnackbarType.success,
        );
        // Auto-close bottom sheet
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context, e.toString(), type: SnackbarType.error);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime d) => DateFormat('d MMM yyyy').format(d);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final debt          = widget.debt;
    final theme         = Theme.of(context);
    // viewInsets.bottom == keyboard height when open, 0 when closed
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      // Smoothly push the sheet up as the keyboard slides in/out
      padding: EdgeInsets.only(bottom: keyboardInset),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false, // required so AnimatedPadding owns the vertical space
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const _DragHandle(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              debt.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          ),
                          _StatusChip(isActive: debt.isActive),
                        ],
                      ),
                      const Gap(24),

                      // Progress (remaining + paid + coloured bar)
                      _ProgressSection(debt: debt),
                      const Gap(24),

                      // Stats grid
                      _StatsGrid(debt: debt, formatDate: _formatDate),
                      const Gap(28),

                      // Section label
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ADD REPAYMENT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: AppColors.grey,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const Gap(16),

                      // Repayment form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextFormField(
                              isRounded: true,
                              label: 'Repayment amount (₦)',
                              hint: '5,000',
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              // When the field is tapped, scroll to the bottom
                              // so it isn't hidden behind the keyboard
                              onTap: () {
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    if (scrollController.hasClients) {
                                      scrollController.animateTo(
                                        scrollController
                                            .position.maxScrollExtent,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  },
                                );
                              },
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                final n = num.tryParse(v);
                                if (n == null || n <= 0) {
                                  return 'Enter a valid amount';
                                }
                                return null;
                              },
                            ),
                            const Gap(16),
                            CustomElevatedButton(
                              text: 'Record repayment',
                              isLoading: _isSubmitting,
                              onPressed:
                                  debt.isActive ? _submitRepayment : null,
                            ),
                            if (!debt.isActive) ...[
                              const Gap(8),
                              Center(
                                child: Text(
                                  'This debt has been fully paid off.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.success,
                                    fontFamily: 'GeneralSans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withOpacity(0.12)
            : AppColors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Paid off',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'GeneralSans',
          color: isActive ? AppColors.success : AppColors.grey,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress section
// debt.balance  = amount already PAID
// debt.owed     = total original debt
// Remaining     = debt.owed - debt.balance
// Already paid  = debt.balance
// Progress      = debt.balance / debt.owed
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.debt});
  final Debt debt;

  @override
  Widget build(BuildContext context) {
    // balance = amount already paid; owed = total original debt
    final alreadyPaid = debt.balance.clamp(0.0, debt.owed);
    final remaining   = (debt.owed - debt.balance).clamp(0.0, debt.owed);
    final progress    = debt.owed > 0
        ? (alreadyPaid / debt.owed).clamp(0.0, 1.0)
        : 0.0;
    final barColor    = _progressColor(progress);
    final pct         = (progress * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Two values side by side ────────────────────────────────────
        Row(
          children: [
            // Remaining
            Expanded(
              child: _ValueLabel(
                title: 'Remaining',
                value: remaining.formatCurrency(),
                valueColor: Colors.black,
              ),
            ),
            const Gap(12),
            // Already paid
            Expanded(
              child: _ValueLabel(
                title: 'Already paid',
                value: alreadyPaid.formatCurrency(),
                valueColor: barColor,
              ),
            ),
          ],
        ),
        const Gap(4),
        // Total owed footnote
        Text(
          'Total owed: ${debt.owed.formatCurrency()}',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.grey,
            fontFamily: 'GeneralSans',
          ),
        ),
        const Gap(12),

        // ── Coloured progress bar ──────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        const Gap(6),

        // ── Percentage label with matching dot ─────────────────────────
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: barColor,
                shape: BoxShape.circle,
              ),
            ),
            const Gap(6),
            Text(
              '$pct% paid off',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.grey,
                fontFamily: 'GeneralSans',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Simple labelled value tile used inside the progress section
class _ValueLabel extends StatelessWidget {
  const _ValueLabel({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.grey,
            fontFamily: 'GeneralSans',
          ),
        ),
        const Gap(2),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'GeneralSans',
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats grid
// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.debt, required this.formatDate});

  final Debt debt;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _StatTile(
                    label: 'Min. payment',
                    value: debt.minPayment.formatCurrency())),
            const Gap(12),
            Expanded(
                child: _StatTile(
                    label: 'Interest rate',
                    value:
                        '${debt.interestRate.toStringAsFixed(1)}%')),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
                child: _StatTile(
                    label: 'Payout preference',
                    value: debt.preferrablePayout)),
            const Gap(12),
            Expanded(
                child: _StatTile(
                    label: 'Target payoff date',
                    value: formatDate(debt.expectedPayoffDate))),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
                child: _StatTile(
                    label: 'Repayment day', value: 'Day ${debt.day}')),
            const Gap(12),
            Expanded(
                child: _StatTile(
                    label: 'Added on', value: formatDate(debt.createdAt))),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey,
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w400,
            ),
          ),
          const Gap(4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'GeneralSans',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:intl/intl.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/debt.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/debt_provider.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // Public entry-point
// // ─────────────────────────────────────────────────────────────────────────────

// class DebtDetailBottomSheet {
//   static Future<void> show(BuildContext context, Debt debt) {
//     return showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => DebtDetailBottomSheetContent(debt: debt),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Bottom sheet content
// // ─────────────────────────────────────────────────────────────────────────────

// class DebtDetailBottomSheetContent extends ConsumerStatefulWidget {
//   const DebtDetailBottomSheetContent({super.key, required this.debt});

//   final Debt debt;

//   @override
//   ConsumerState<DebtDetailBottomSheetContent> createState() =>
//       _DebtDetailBottomSheetContentState();
// }

// class _DebtDetailBottomSheetContentState
//     extends ConsumerState<DebtDetailBottomSheetContent> {
//   final _amountController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isSubmitting = false;

//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Repayment
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _submitRepayment() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSubmitting = true);

//     try {
//       await ref.read(debtListNotifierProvider.notifier).manualFundDebt(
//             widget.debt.id,
//             _amountController.text.trim(),
//           );

//       if (mounted) {
//         _amountController.clear();
//         CustomSnackbar.show(
//           context,
//           'Repayment recorded successfully',
//           type: SnackbarType.success,
//         );
//         Navigator.of(context).pop(); // close sheet
//       }
//     } catch (e) {
//       if (mounted) {
//         CustomSnackbar.show(
//           context,
//           e.toString(),
//           type: SnackbarType.error,
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Helpers
//   // ─────────────────────────────────────────────────────────────────────────

//   String _formatDate(DateTime date) =>
//       DateFormat('d MMM yyyy').format(date);

//   String _formatCurrency(double value) => value.formatCurrency();

//   // ─────────────────────────────────────────────────────────────────────────
//   // Build
//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final debt = widget.debt;
//     final theme = Theme.of(context);

//     return DraggableScrollableSheet(
//       initialChildSize: 0.75,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: Column(
//             children: [
//               // ── Drag handle ──────────────────────────────────────────────
//               const _DragHandle(),

//               // ── Scrollable body ──────────────────────────────────────────
//               Expanded(
//                 child: ListView(
//                   controller: scrollController,
//                   padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
//                   children: [
//                     // ── Header ─────────────────────────────────────────────
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             debt.name,
//                             style: theme.textTheme.titleLarge?.copyWith(
//                               fontWeight: FontWeight.w600,
//                               fontFamily: 'GeneralSans',
//                             ),
//                           ),
//                         ),
//                         _StatusChip(isActive: debt.isActive),
//                       ],
//                     ),
//                     const Gap(24),

//                     // ── Progress bar ───────────────────────────────────────
//                     _ProgressSection(debt: debt),
//                     const Gap(24),

//                     // ── Key stats grid ─────────────────────────────────────
//                     _StatsGrid(debt: debt, formatDate: _formatDate),
//                     const Gap(28),

//                     // ── Repayment divider ──────────────────────────────────
//                     Row(
//                       children: [
//                         const Expanded(child: Divider()),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: Text(
//                             'ADD REPAYMENT',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 1.2,
//                               color: AppColors.grey,
//                               fontFamily: 'GeneralSans',
//                             ),
//                           ),
//                         ),
//                         const Expanded(child: Divider()),
//                       ],
//                     ),
//                     const Gap(16),

//                     // ── Repayment form ─────────────────────────────────────
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           CustomTextFormField(
//                             isRounded: true,
//                             label: 'Repayment amount (₦)',
//                             hint: '5,000',
//                             controller: _amountController,
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                             ],
//                             validator: (v) {
//                               if (v == null || v.isEmpty) return 'Required';
//                               final n = num.tryParse(v);
//                               if (n == null || n <= 0) {
//                                 return 'Enter a valid amount';
//                               }
//                               return null;
//                             },
//                           ),
//                           const Gap(8),
//                           Text(
//                             'Remaining balance: ${_formatCurrency(debt.balance)}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppColors.grey,
//                               fontFamily: 'GeneralSans',
//                             ),
//                           ),
//                           const Gap(16),
//                           CustomElevatedButton(
//                             text: 'Record repayment',
//                             isLoading: _isSubmitting,
//                             onPressed: debt.isActive ? _submitRepayment : null,
//                           ),
//                           if (!debt.isActive) ...[
//                             const Gap(8),
//                             Center(
//                               child: Text(
//                                 'This debt has been paid off.',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: AppColors.success,
//                                   fontFamily: 'GeneralSans',
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Sub-widgets
// // ─────────────────────────────────────────────────────────────────────────────

// class _DragHandle extends StatelessWidget {
//   const _DragHandle();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Center(
//         child: Container(
//           width: 40,
//           height: 4,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _StatusChip extends StatelessWidget {
//   const _StatusChip({required this.isActive});

//   final bool isActive;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: isActive
//             ? AppColors.success.withOpacity(0.12)
//             : AppColors.grey.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         isActive ? 'Active' : 'Paid off',
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           fontFamily: 'GeneralSans',
//           color: isActive ? AppColors.success : AppColors.grey,
//         ),
//       ),
//     );
//   }
// }

// class _ProgressSection extends StatelessWidget {
//   const _ProgressSection({required this.debt});

//   final Debt debt;

//   @override
//   Widget build(BuildContext context) {
//     final paid    = debt.owed - debt.balance;
//     final progress = debt.progress;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               debt.balance.formatCurrency(),
//               style: const TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'GeneralSans',
//               ),
//             ),
//             Text(
//               'of ${debt.owed.formatCurrency()}',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: AppColors.grey,
//                 fontFamily: 'GeneralSans',
//               ),
//             ),
//           ],
//         ),
//         const Gap(4),
//         Text(
//           'remaining',
//           style: TextStyle(
//             fontSize: 12,
//             color: AppColors.grey,
//             fontFamily: 'GeneralSans',
//           ),
//         ),
//         const Gap(12),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(6),
//           child: LinearProgressIndicator(
//             value: progress,
//             minHeight: 10,
//             backgroundColor: Colors.grey.shade200,
//             valueColor: AlwaysStoppedAnimation<Color>(
//               progress >= 1.0 ? AppColors.success : AppColors.primary,
//             ),
//           ),
//         ),
//         const Gap(4),
//         Text(
//           '${(progress * 100).toStringAsFixed(1)}% paid off  •  '
//           '${paid.formatCurrency()} repaid',
//           style: TextStyle(
//             fontSize: 11,
//             color: AppColors.grey,
//             fontFamily: 'GeneralSans',
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _StatsGrid extends StatelessWidget {
//   const _StatsGrid({required this.debt, required this.formatDate});

//   final Debt debt;
//   final String Function(DateTime) formatDate;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _StatTile(
//                 label: 'Min. payment',
//                 value: debt.minPayment.formatCurrency(),
//               ),
//             ),
//             const Gap(12),
//             Expanded(
//               child: _StatTile(
//                 label: 'Interest rate',
//                 value: '${debt.interestRate.toStringAsFixed(1)}%',
//               ),
//             ),
//           ],
//         ),
//         const Gap(12),
//         Row(
//           children: [
//             Expanded(
//               child: _StatTile(
//                 label: 'Payout preference',
//                 value: debt.preferrablePayout,
//               ),
//             ),
//             const Gap(12),
//             Expanded(
//               child: _StatTile(
//                 label: 'Target payoff date',
//                 value: formatDate(debt.expectedPayoffDate),
//               ),
//             ),
//           ],
//         ),
//         const Gap(12),
//         Row(
//           children: [
//             Expanded(
//               child: _StatTile(
//                 label: 'Repayment day',
//                 value: 'Day ${debt.day}',
//               ),
//             ),
//             const Gap(12),
//             Expanded(
//               child: _StatTile(
//                 label: 'Added on',
//                 value: formatDate(debt.createdAt),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _StatTile extends StatelessWidget {
//   const _StatTile({required this.label, required this.value});

//   final String label;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               color: AppColors.grey,
//               fontFamily: 'GeneralSans',
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           const Gap(4),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'GeneralSans',
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }