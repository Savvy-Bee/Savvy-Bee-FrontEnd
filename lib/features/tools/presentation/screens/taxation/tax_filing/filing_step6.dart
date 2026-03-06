// lib/features/tools/presentation/screens/taxation/filing/filing_step6_screen.dart
//
// CHANGES vs previous version:
//   • Reads real status from filingLiabilityResultProvider (set by Step 5)
//   • Falls back to fillingProcess.status when resumed
//   • Status-aware UI: ValidatingTax / Completed / Rejected / Failed messaging
//   • Download proof of filing includes status text
//   • "View my filing record" navigates to FilingRecord with real data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

const _planFees = <String, double>{
  'Basic PAYE': 7500,
  'Freelancer': 25000,
  'Freelance': 25000,
  'SME Lite': 75000,
  'Pro / Complex': 0,
  'Pro Complex': 0,
};

class FilingStep6Screen extends ConsumerWidget {
  static const String path = FilingRoutes.step6;
  const FilingStep6Screen({super.key});

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxDue = ref.watch(filingTaxDueProvider);
    final selectedPlan = ref.watch(selectedFilingPlanProvider);
    final filingFee = _planFees[selectedPlan] ?? 0.0;
    final taxYear = DateTime.now().year - 1;

    // Determine current status
    final liabilityResult = ref.watch(filingLiabilityResultProvider);
    final filingData = ref.watch(filingHomeProvider).value;
    final FillingStatus status = liabilityResult?.status ??
        filingData?.fillingProcess?.status ??
        FillingStatus.validatingTax;

    final _StatusConfig cfg = _StatusConfig.from(status);

    // Reference number
    final refNo =
        'SB-$taxYear-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Hero ──────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                      24, MediaQuery.of(context).padding.top + 40, 24, 32),
                  child: Column(children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: cfg.iconBg, shape: BoxShape.circle),
                      child: Icon(cfg.icon, color: cfg.iconColor, size: 36),
                    ),
                    const Gap(20),
                    Text(cfg.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 26 * 0.02, height: 1.2)),
                    const Gap(10),
                    Text(cfg.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'GeneralSans', fontSize: 13, color: AppColors.greyDark, letterSpacing: 13 * 0.02)),
                  ]),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Filing Progress', style: TextStyle(fontFamily: 'GeneralSans', fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 16 * 0.02)),
                    const Gap(16),
                    _ProgressTimeline(status: status),
                    const Gap(20),

                    // Status-specific info card
                    if (status == FillingStatus.rejected || status == FillingStatus.failed)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [
                          const Icon(Icons.error_outline, size: 18, color: Colors.redAccent),
                          Expanded(child: Text(status == FillingStatus.rejected ? 'Your return was rejected by the tax authority. A Savvy Bee partner will reach out with next steps.' : 'An issue occurred with your filing. Please contact support or try again.', style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 12, color: Colors.redAccent, letterSpacing: 12 * 0.02))),
                        ]),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2))),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [
                          const Icon(Icons.notifications_active_outlined, size: 18, color: Colors.blueAccent),
                          Expanded(child: Text(
                            "You'll be notified at each stage\n\nPush notification + in-app message when validated and submitted. Final confirmation: \"Done. Savvy Bee has filed your $taxYear tax return.\"",
                            style: TextStyle(fontFamily: 'GeneralSans', fontSize: 12, color: Colors.blueAccent.shade700, letterSpacing: 12 * 0.02, height: 1.5),
                          )),
                        ]),
                      ),
                    const Gap(24),

                    const Text('Filing Record', style: TextStyle(fontFamily: 'GeneralSans', fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 16 * 0.02)),
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        _RecordRow(label: 'Tax year', value: '$taxYear'),
                        _RecordRow(label: 'Filing tier', value: selectedPlan),
                        _RecordRow(label: 'Tax paid', value: taxDue.formatCurrency(decimalDigits: 0)),
                        _RecordRow(label: 'Filing fee', value: filingFee > 0 ? filingFee.formatCurrency(decimalDigits: 0) : 'Custom quote'),
                        _RecordRow(label: 'Reference', value: refNo),
                        _RecordRow(label: 'Status', value: status.displayLabel),
                        const Gap(12),
                        OutlinedButton.icon(
                          onPressed: () => _downloadProof(context, taxYear: taxYear, selectedPlan: selectedPlan, taxDue: taxDue, filingFee: filingFee, refNo: refNo, status: status),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF43A047)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.download_outlined, size: 16, color: Color(0xFF43A047)),
                          label: const Text('Download proof of filing', style: TextStyle(fontFamily: 'GeneralSans', fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF43A047), letterSpacing: 13 * 0.02)),
                        ),
                      ]),
                    ),
                    const Gap(24),
                  ]),
                ),
              ],
            ),
          ),
          BottomActionButton(
            label: 'View my filing record',
            onTap: () => context.pushNamed(FilingRoutes.filingRecord),
          ),
        ],
      ),
    );
  }

  void _downloadProof(
    BuildContext context, {
    required int taxYear,
    required String selectedPlan,
    required double taxDue,
    required double filingFee,
    required String refNo,
    required FillingStatus status,
  }) {
    // TODO: integrate real PDF generation / download
    AppNotification.show(
      context,
      message: 'Proof of filing prepared for $taxYear (${status.displayLabel}). Download will begin shortly.',
      icon: Icons.download_outlined,
      iconColor: const Color(0xFF43A047),
    );
  }
}

// ── Status config ─────────────────────────────────────────────────────────────

class _StatusConfig {
  final Color iconBg, iconColor;
  final IconData icon;
  final String title, subtitle;

  const _StatusConfig({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  factory _StatusConfig.from(FillingStatus status) {
    switch (status) {
      case FillingStatus.completed:
        return const _StatusConfig(
          iconBg: Color(0xFF43A047),
          iconColor: Colors.white,
          icon: Icons.check,
          title: 'Filing complete!',
          subtitle: 'Your return has been successfully filed with FIRS.',
        );
      case FillingStatus.rejected:
        return _StatusConfig(
          iconBg: Colors.red.shade50,
          iconColor: Colors.redAccent,
          icon: Icons.close,
          title: 'Return rejected',
          subtitle: 'Your return was rejected. A partner will contact you with next steps.',
        );
      case FillingStatus.failed:
        return _StatusConfig(
          iconBg: Colors.red.shade50,
          iconColor: Colors.redAccent,
          icon: Icons.error_outline,
          title: 'Filing failed',
          subtitle: 'Something went wrong. Please contact support or try again.',
        );
      default: // ValidatingTax, PayedLiabilityFee, unknown
        return const _StatusConfig(
          iconBg: Color(0xFFF5C842),
          iconColor: Colors.black,
          icon: Icons.check,
          title: 'Your return is with\nyour partner',
          subtitle: "We'll notify you once it's validated and submitted — usually within 24–48 hours.",
        );
    }
  }
}

// ── Progress timeline ─────────────────────────────────────────────────────────

class _ProgressTimeline extends StatelessWidget {
  final FillingStatus status;
  const _ProgressTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final isRejected = status == FillingStatus.rejected || status == FillingStatus.failed;
    final isCompleted = status == FillingStatus.completed;

    return Column(children: [
      _TimelineStep(label: 'Reviewed', sublabel: 'Return confirmed by you', stepStatus: _StepStatus.done, isLast: false),
      _TimelineStep(
        label: 'Validated',
        sublabel: isRejected ? 'Rejected by tax authority' : isCompleted ? 'Approved by partner' : 'Partner reviewing — 24–48 hrs',
        stepStatus: isRejected ? _StepStatus.rejected : isCompleted ? _StepStatus.done : _StepStatus.inProgress,
        badge: isRejected ? 'REJECTED' : isCompleted ? null : 'IN PROGRESS',
        isLast: false,
      ),
      _TimelineStep(
        label: 'Submitted',
        sublabel: isCompleted ? 'Filed with FIRS' : 'Pending submission',
        stepStatus: isCompleted ? _StepStatus.done : _StepStatus.pending,
        isLast: true,
      ),
    ]);
  }
}

enum _StepStatus { done, inProgress, pending, rejected }

class _TimelineStep extends StatelessWidget {
  final String label, sublabel;
  final _StepStatus stepStatus;
  final String? badge;
  final bool isLast;
  static const _yellow = Color(0xFFF5C842);
  const _TimelineStep({required this.label, required this.sublabel, required this.stepStatus, this.badge, required this.isLast});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 32, child: Column(children: [
            _buildIndicator(),
            if (!isLast) Container(width: 2, height: 48, color: stepStatus == _StepStatus.done ? Colors.black87 : AppColors.borderLight),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 2),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontFamily: 'GeneralSans', fontSize: 14, fontWeight: FontWeight.w600, color: stepStatus == _StepStatus.pending ? AppColors.grey : Colors.black87, letterSpacing: 14 * 0.02)),
                const Gap(2),
                Text(sublabel, style: TextStyle(fontFamily: 'GeneralSans', fontSize: 12, color: AppColors.greyDark, letterSpacing: 12 * 0.02)),
              ])),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  decoration: BoxDecoration(color: stepStatus == _StepStatus.rejected ? Colors.redAccent : _yellow, borderRadius: BorderRadius.circular(50)),
                  child: Text(badge!, style: TextStyle(fontFamily: 'GeneralSans', fontSize: 9, fontWeight: FontWeight.w700, color: stepStatus == _StepStatus.rejected ? Colors.white : Colors.black, letterSpacing: 9 * 0.02)),
                ),
            ]),
          )),
        ],
      );

  Widget _buildIndicator() {
    switch (stepStatus) {
      case _StepStatus.done:
        return Container(width: 26, height: 26, decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 14));
      case _StepStatus.inProgress:
        return Container(width: 26, height: 26, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _yellow, width: 2.5), color: Colors.white), child: Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: _yellow, shape: BoxShape.circle))));
      case _StepStatus.rejected:
        return Container(width: 26, height: 26, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 14));
      case _StepStatus.pending:
        return Container(width: 26, height: 26, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.borderLight, width: 2), color: Colors.white));
    }
  }
}

class _RecordRow extends StatelessWidget {
  final String label, value;
  const _RecordRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(fontFamily: 'GeneralSans', fontSize: 13, color: AppColors.greyDark, letterSpacing: 13 * 0.02)),
          Text(value, style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 13 * 0.02)),
        ]),
      );
}




// // lib/features/tools/presentation/screens/taxation/filing/filing_step6_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_tax_due_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/selected_filing_plan_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

// // ── Plan → filing fee (mirrors Step 4) ───────────────────────────────────────
// const _planFees = <String, double>{
//   'Basic PAYE': 7500,
//   'Freelancer': 25000,
//   'SME Lite': 75000,
//   'Pro / Complex': 0,
// };

// class FilingStep6Screen extends ConsumerWidget {
//   static const String path = FilingRoutes.step6;

//   const FilingStep6Screen({super.key});

//   static const _yellow = Color(0xFFF5C842);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final taxDue = ref.watch(filingTaxDueProvider);
//     final selectedPlan = ref.watch(selectedFilingPlanProvider);
//     final filingFee = _planFees[selectedPlan] ?? 0.0;
//     final taxYear = DateTime.now().year - 1;

//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 // ── Hero ──────────────────────────────────────────────
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.fromLTRB(
//                     24,
//                     MediaQuery.of(context).padding.top + 40,
//                     24,
//                     32,
//                   ),
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 72,
//                         height: 72,
//                         decoration: const BoxDecoration(
//                           color: _yellow,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.check,
//                           color: Colors.black,
//                           size: 36,
//                         ),
//                       ),
//                       const Gap(20),
//                       const Text(
//                         'Your return is with\nyour partner',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 26,
//                           fontWeight: FontWeight.w700,
//                           letterSpacing: 26 * 0.02,
//                           height: 1.2,
//                         ),
//                       ),
//                       const Gap(10),
//                       Text(
//                         'We\'ll notify you once it\'s validated and submitted — usually within 24–48 hours.',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 13,
//                           color: AppColors.greyDark,
//                           letterSpacing: 13 * 0.02,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ── Filing progress ───────────────────────────
//                       const Text(
//                         'Filing Progress',
//                         style: TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 16 * 0.02,
//                         ),
//                       ),
//                       const Gap(16),
//                       const _ProgressTimeline(),
//                       const Gap(20),

//                       // ── Notification info card ────────────────────
//                       Container(
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF0F4FF),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: Colors.blueAccent.withValues(alpha: 0.2),
//                           ),
//                         ),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           spacing: 10,
//                           children: [
//                             const Icon(
//                               Icons.notifications_active_outlined,
//                               size: 18,
//                               color: Colors.blueAccent,
//                             ),
//                             Expanded(
//                               child: Text(
//                                 'You\'ll be notified at each stage\n\nPush notification + in-app message when validated and submitted. Final confirmation: "Done. Savvy Bee has filed your $taxYear tax return."',
//                                 style: TextStyle(
//                                   fontFamily: 'GeneralSans',
//                                   fontSize: 12,
//                                   color: Colors.blueAccent.shade700,
//                                   letterSpacing: 12 * 0.02,
//                                   height: 1.5,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Gap(24),

//                       // ── Filing record ─────────────────────────────
//                       const Text(
//                         'Filing Record',
//                         style: TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 16 * 0.02,
//                         ),
//                       ),
//                       const Gap(12),
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: AppColors.borderLight),
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: Column(
//                           children: [
//                             _RecordRow(label: 'Tax year', value: '$taxYear'),
//                             _RecordRow(
//                               label: 'Filing tier',
//                               value: selectedPlan,
//                             ),
//                             _RecordRow(
//                               label: 'Tax paid',
//                               value: taxDue.formatCurrency(decimalDigits: 0),
//                             ),
//                             _RecordRow(
//                               label: 'Filing fee',
//                               value: filingFee > 0
//                                   ? filingFee.formatCurrency(decimalDigits: 0)
//                                   : 'Custom quote',
//                             ),
//                             _RecordRow(
//                               label: 'Reference',
//                               value:
//                                   'SB-$taxYear-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
//                             ),
//                             const Gap(12),
//                             OutlinedButton.icon(
//                               onPressed: () {},
//                               style: OutlinedButton.styleFrom(
//                                 side: const BorderSide(
//                                   color: Color(0xFF43A047),
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 12,
//                                 ),
//                               ),
//                               icon: const Icon(
//                                 Icons.download_outlined,
//                                 size: 16,
//                                 color: Color(0xFF43A047),
//                               ),
//                               label: const Text(
//                                 'Download proof of filing',
//                                 style: TextStyle(
//                                   fontFamily: 'GeneralSans',
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                   color: Color(0xFF43A047),
//                                   letterSpacing: 13 * 0.02,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Gap(24),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           BottomActionButton(
//             label: 'View my filing record',
//             onTap: () => context.pushNamed(FilingRoutes.filingRecord),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Progress timeline ─────────────────────────────────────────────────────────

// class _ProgressTimeline extends StatelessWidget {
//   static const _yellow = Color(0xFFF5C842);

//   const _ProgressTimeline();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: const [
//         _TimelineStep(
//           label: 'Reviewed',
//           sublabel: 'Return confirmed by you',
//           status: _StepStatus.done,
//           isLast: false,
//         ),
//         _TimelineStep(
//           label: 'Validated',
//           sublabel: 'Partner reviewing — 24–48 hrs',
//           status: _StepStatus.inProgress,
//           badge: 'IN PROGRESS',
//           isLast: false,
//         ),
//         _TimelineStep(
//           label: 'Submitted',
//           sublabel: 'Filed with FIRS',
//           status: _StepStatus.pending,
//           isLast: true,
//         ),
//       ],
//     );
//   }
// }

// enum _StepStatus { done, inProgress, pending }

// class _TimelineStep extends StatelessWidget {
//   final String label;
//   final String sublabel;
//   final _StepStatus status;
//   final String? badge;
//   final bool isLast;

//   static const _yellow = Color(0xFFF5C842);

//   const _TimelineStep({
//     required this.label,
//     required this.sublabel,
//     required this.status,
//     this.badge,
//     required this.isLast,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 32,
//           child: Column(
//             children: [
//               _buildIndicator(),
//               if (!isLast)
//                 Container(
//                   width: 2,
//                   height: 48,
//                   color: status == _StepStatus.done
//                       ? Colors.black87
//                       : AppColors.borderLight,
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 8, top: 2),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         label,
//                         style: TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: status == _StepStatus.pending
//                               ? AppColors.grey
//                               : Colors.black87,
//                           letterSpacing: 14 * 0.02,
//                         ),
//                       ),
//                       const Gap(2),
//                       Text(
//                         sublabel,
//                         style: TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 12,
//                           color: AppColors.greyDark,
//                           letterSpacing: 12 * 0.02,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (badge != null)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 3,
//                       horizontal: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _yellow,
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: Text(
//                       badge!,
//                       style: const TextStyle(
//                         fontFamily: 'GeneralSans',
//                         fontSize: 9,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black,
//                         letterSpacing: 9 * 0.02,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildIndicator() {
//     switch (status) {
//       case _StepStatus.done:
//         return Container(
//           width: 26,
//           height: 26,
//           decoration: const BoxDecoration(
//             color: Colors.black87,
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(Icons.check, color: Colors.white, size: 14),
//         );
//       case _StepStatus.inProgress:
//         return Container(
//           width: 26,
//           height: 26,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: _yellow, width: 2.5),
//             color: Colors.white,
//           ),
//           child: Center(
//             child: Container(
//               width: 10,
//               height: 10,
//               decoration: const BoxDecoration(
//                 color: _yellow,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//         );
//       case _StepStatus.pending:
//         return Container(
//           width: 26,
//           height: 26,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: AppColors.borderLight, width: 2),
//             color: Colors.white,
//           ),
//         );
//     }
//   }
// }

// // ── Record row ────────────────────────────────────────────────────────────────

// class _RecordRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _RecordRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontFamily: 'GeneralSans',
//               fontSize: 13,
//               color: AppColors.greyDark,
//               letterSpacing: 13 * 0.02,
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontFamily: 'GeneralSans',
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               letterSpacing: 13 * 0.02,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
