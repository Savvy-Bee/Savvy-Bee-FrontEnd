// lib/features/tools/presentation/screens/taxation/filing/tin_validation_screen1.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/tin_validation_provider.dart';

class TinValidationScreen1 extends ConsumerStatefulWidget {
  static const String path = FilingRoutes.tinValidation1;

  const TinValidationScreen1({super.key});

  @override
  ConsumerState<TinValidationScreen1> createState() =>
      _TinValidationScreen1State();
}

class _TinValidationScreen1State extends ConsumerState<TinValidationScreen1> {
  final _tinCtrl = TextEditingController();
  bool _isLoading = false;

  static const _yellow = Color(0xFFF5C842);

  static TextStyle _gs(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = Colors.black87,
  }) => TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: size * 0.02,
  );

  @override
  void initState() {
    super.initState();
    _tinCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tinCtrl.dispose();
    super.dispose();
  }

  int get _digitCount => _tinCtrl.text.trim().length;
  bool get _canValidate => _digitCount >= 10 && !_isLoading;

  Future<void> _validate() async {
    if (!_canValidate) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final tin = _tinCtrl.text.trim();

    try {
      // ── 1. Call the TIN validation API ──────────────────────────────
      final repo = ref.read(tinValidationRepositoryProvider);
      final result = await repo.validateTin(tin);

      // ── 2. Store result — Screen 2 reads from this provider ─────────
      ref.read(tinValidationResultProvider.notifier).state = result;

      // ── 3. Persist TIN so Step 3 payment/init can include it ─────────
      ref.read(filingTinProvider.notifier).state = tin;

      // ── 4. Fetch Filing Home Data NOW so resume check has fresh data ──
      //
      // The provider may not have been loaded yet at this point in the
      // flow. We explicitly trigger a refresh so that fillingProcess
      // reflects the server's current state before we decide where to go.
      await ref.read(filingHomeProvider.notifier).refresh();

      if (!mounted) return;
      setState(() => _isLoading = false);

      // ── 5. Check for active filing process → resume if needed ────────
      final filingData = ref.read(filingHomeProvider).value;
      final resumeRoute = resumeRouteFor(filingData?.fillingProcess);

      if (resumeRoute != null) {
        final process = filingData!.fillingProcess!;
        ref.read(selectedFilingPlanProvider.notifier).state = process.plan;
        ref.read(filingTaxDueProvider.notifier).state =
            process.financeDetails.taxAmount;

        AppNotification.show(
          context,
          message:
              'Welcome back! Resuming your ${process.status.displayLabel} filing.',
          icon: Icons.restart_alt_outlined,
        );
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) context.pushNamed(resumeRoute);
      } else {
        // ── 5. Normal flow → Screen 2 ──────────────────────────────────
        context.pushNamed(FilingRoutes.tinValidation2);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      AppNotification.show(
        context,
        message: _friendlyError(e.toString()),
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
      );
    }
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('404') || lower.contains('not found')) {
      return 'TIN not found. Please check the number and try again.';
    }
    if (lower.contains('401') || lower.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    }
    if (lower.contains('timeout') || lower.contains('socket')) {
      return 'Network error. Please check your connection and try again.';
    }
    return 'Validation failed. Please check the TIN and try again.';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(
            'TIN Validation',
            style: _gs(16, weight: FontWeight.w600),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StepBadge(label: 'EXISTING TAXPAYER · TIN LOOKUP'),
                const Gap(20),

                Text(
                  'Enter your Tax\nIdentification Number',
                  style: _gs(26, weight: FontWeight.w700),
                ),
                const Gap(10),
                Text(
                  "We'll verify your TIN with the Joint Tax Board (JTB)\nportal and pull in your tax records automatically.",
                  style: _gs(13, color: AppColors.greyDark),
                ),
                const Gap(36),

                Text(
                  'TIN (10–13 digits)',
                  style: _gs(13, color: AppColors.greyDark),
                ),
                const Gap(10),

                TextField(
                  controller: _tinCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  style: _gs(
                    28,
                    weight: FontWeight.w500,
                    color: _digitCount > 0
                        ? Colors.black87
                        : const Color(0xFFCCCCCC),
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. 1234567890',
                    hintStyle: _gs(
                      28,
                      weight: FontWeight.w400,
                      color: const Color(0xFFCCCCCC),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
                const Gap(6),

                Divider(
                  height: 1,
                  thickness: 1.5,
                  color: _digitCount >= 10 ? _yellow : const Color(0xFFE5E5E5),
                ),
                const Gap(8),

                Text(
                  '$_digitCount digits · Find your TIN on your FIRS certificate or payslip',
                  style: _gs(12, color: AppColors.greyDark),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canValidate ? _validate : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _yellow,
                      disabledBackgroundColor: const Color(
                        0xFFF5C842,
                      ).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'Validate my TIN',
                            style: _gs(
                              15,
                              weight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
          color: Color(0xFFF5C842),
          letterSpacing: 11 * 0.02,
        ),
      ),
    ],
  );
}



// // lib/features/tools/presentation/screens/taxation/filing/tin_validation_screen1.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
// import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/tin_validation_provider.dart';

// class TinValidationScreen1 extends ConsumerStatefulWidget {
//   static const String path = FilingRoutes.tinValidation1;

//   const TinValidationScreen1({super.key});

//   @override
//   ConsumerState<TinValidationScreen1> createState() =>
//       _TinValidationScreen1State();
// }

// class _TinValidationScreen1State extends ConsumerState<TinValidationScreen1> {
//   final _tinCtrl = TextEditingController();
//   bool _isLoading = false;

//   static const _yellow = Color(0xFFF5C842);

//   static TextStyle _gs(
//     double size, {
//     FontWeight weight = FontWeight.w400,
//     Color color = Colors.black87,
//   }) => TextStyle(
//     fontFamily: 'GeneralSans',
//     fontSize: size,
//     fontWeight: weight,
//     color: color,
//     letterSpacing: size * 0.02,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _tinCtrl.addListener(() => setState(() {}));
//   }

//   @override
//   void dispose() {
//     _tinCtrl.dispose();
//     super.dispose();
//   }

//   int get _digitCount => _tinCtrl.text.trim().length;
//   bool get _canValidate => _digitCount >= 10 && !_isLoading;

//   Future<void> _validate() async {
//     if (!_canValidate) return;
//     FocusScope.of(context).unfocus();
//     setState(() => _isLoading = true);

//     final tin = _tinCtrl.text.trim();

//     try {
//       // ── 1. Call the TIN validation API ──────────────────────────────
//       final repo = ref.read(tinValidationRepositoryProvider);
//       final result = await repo.validateTin(tin);

//       // ── 2. Store result — Screen 2 reads from this provider ─────────
//       ref.read(tinValidationResultProvider.notifier).state = result;

//       // ── 3. Persist TIN so Step 3 payment/init can include it ─────────
//       ref.read(filingTinProvider.notifier).state = tin;

//       if (!mounted) return;
//       setState(() => _isLoading = false);

//       // ── 4. Check for active filing process → resume if needed ────────
//       final filingData = ref.read(filingHomeProvider).value;
//       print('About to Redirect to resumption if any---');
//       final resumeRoute = resumeRouteFor(filingData?.fillingProcess);

//       if (resumeRoute != null) {
//         final process = filingData!.fillingProcess!;
//         ref.read(selectedFilingPlanProvider.notifier).state = process.plan;
//         ref.read(filingTaxDueProvider.notifier).state =
//             process.financeDetails.taxAmount;

//         AppNotification.show(
//           context,
//           message:
//               'Welcome back! Resuming your ${process.status.displayLabel} filing.',
//           icon: Icons.restart_alt_outlined,
//         );
//         await Future.delayed(const Duration(milliseconds: 600));
//         if (mounted) context.pushNamed(resumeRoute);
//       } else {
//         // ── 5. Normal flow → Screen 2 ──────────────────────────────────
//         context.pushNamed(FilingRoutes.tinValidation2);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoading = false);

//       AppNotification.show(
//         context,
//         message: _friendlyError(e.toString()),
//         icon: Icons.error_outline,
//         iconColor: Colors.redAccent,
//       );
//     }
//   }

//   String _friendlyError(String raw) {
//     final lower = raw.toLowerCase();
//     if (lower.contains('404') || lower.contains('not found')) {
//       return 'TIN not found. Please check the number and try again.';
//     }
//     if (lower.contains('401') || lower.contains('unauthorized')) {
//       return 'Session expired. Please log in again.';
//     }
//     if (lower.contains('timeout') || lower.contains('socket')) {
//       return 'Network error. Please check your connection and try again.';
//     }
//     return 'Validation failed. Please check the TIN and try again.';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           leading: const BackButton(),
//           title: Text(
//             'TIN Validation',
//             style: _gs(16, weight: FontWeight.w600),
//           ),
//           centerTitle: false,
//           elevation: 0,
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black87,
//         ),
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const _StepBadge(label: 'EXISTING TAXPAYER · TIN LOOKUP'),
//                 const Gap(20),

//                 Text(
//                   'Enter your Tax\nIdentification Number',
//                   style: _gs(26, weight: FontWeight.w700),
//                 ),
//                 const Gap(10),
//                 Text(
//                   "We'll verify your TIN with the Joint Tax Board (JTB)\nportal and pull in your tax records automatically.",
//                   style: _gs(13, color: AppColors.greyDark),
//                 ),
//                 const Gap(36),

//                 Text(
//                   'TIN (10–13 digits)',
//                   style: _gs(13, color: AppColors.greyDark),
//                 ),
//                 const Gap(10),

//                 TextField(
//                   controller: _tinCtrl,
//                   keyboardType: TextInputType.number,
//                   autofocus: true,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(13),
//                   ],
//                   style: _gs(
//                     28,
//                     weight: FontWeight.w500,
//                     color: _digitCount > 0
//                         ? Colors.black87
//                         : const Color(0xFFCCCCCC),
//                   ),
//                   decoration: InputDecoration(
//                     hintText: 'e.g. 1234567890',
//                     hintStyle: _gs(
//                       28,
//                       weight: FontWeight.w400,
//                       color: const Color(0xFFCCCCCC),
//                     ),
//                     border: InputBorder.none,
//                     enabledBorder: InputBorder.none,
//                     focusedBorder: InputBorder.none,
//                     contentPadding: EdgeInsets.zero,
//                     isDense: true,
//                   ),
//                 ),
//                 const Gap(6),

//                 Divider(
//                   height: 1,
//                   thickness: 1.5,
//                   color: _digitCount >= 10 ? _yellow : const Color(0xFFE5E5E5),
//                 ),
//                 const Gap(8),

//                 Text(
//                   '$_digitCount digits · Find your TIN on your FIRS certificate or payslip',
//                   style: _gs(12, color: AppColors.greyDark),
//                 ),

//                 const Spacer(),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _canValidate ? _validate : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _yellow,
//                       disabledBackgroundColor: const Color(
//                         0xFFF5C842,
//                       ).withValues(alpha: 0.35),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       elevation: 0,
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2.5,
//                               color: Colors.black,
//                             ),
//                           )
//                         : Text(
//                             'Validate my TIN',
//                             style: _gs(
//                               15,
//                               weight: FontWeight.w600,
//                               color: Colors.black,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
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
//           color: Color(0xFFF5C842),
//           letterSpacing: 11 * 0.02,
//         ),
//       ),
//     ],
//   );
// }