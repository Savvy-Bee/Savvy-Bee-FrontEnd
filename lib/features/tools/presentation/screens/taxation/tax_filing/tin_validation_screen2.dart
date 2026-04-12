// lib/features/tools/presentation/screens/taxation/filing/tin_validation_screen2.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/home/domain/models/home_data.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/tin_validation_repository.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/tin_validation_provider.dart';

class TinValidationScreen2 extends ConsumerWidget {
  static const String path = FilingRoutes.tinValidation2;

  const TinValidationScreen2({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(tinValidationResultProvider);
    final homeAsync = ref.watch(homeDataProvider);
    final homeData = homeAsync.value?.data;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('TIN Validation', style: _gs(16, weight: FontWeight.w600)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Badge ─────────────────────────────────────────────────
                  const _StepBadge(label: 'EXISTING TAXPAYER · TIN LOOKUP'),
                  const Gap(20),

                  // ── Headline ──────────────────────────────────────────────
                  Text(
                    'Enter your Tax\nIdentification Number',
                    style: _gs(26, weight: FontWeight.w700),
                  ),
                  const Gap(10),
                  Text(
                    "We'll verify your TIN with the Joint Tax Board (JTB)\nportal and pull in your tax records automatically.",
                    style: _gs(13, color: AppColors.greyDark),
                  ),
                  const Gap(24),

                  // ── Validated card ────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: result == null
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(
                                color: _yellow,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : _ValidatedCardContent(result: result, profile: homeData),
                  ),
                  const Gap(16),

                  // ── Success note ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FFF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF43A047).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 15,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your tax records have been fetched and your return pre-filled. You can review everything before confirming.',
                            style: _gs(12, color: const Color(0xFF2E7D32)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── CTA ───────────────────────────────────────────────────
                  const Gap(24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: result != null
                          ? () => context.pushNamed(FilingRoutes.filingCountrySelect)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _yellow,
                        disabledBackgroundColor: _yellow.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(
                        'Proceed to filing',
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
      ),
    );
  }
}

// ── Validated card content ────────────────────────────────────────────────────

class _ValidatedCardContent extends StatelessWidget {
  final TinValidationResult result;
  final HomeData? profile;

  const _ValidatedCardContent({required this.result, this.profile});

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
  Widget build(BuildContext context) {
    // ── Resolve display values from profile (with TIN result as fallback) ──
    final fullName = profile != null
        ? '${profile!.firstName} ${profile!.lastName}'.trim()
        : result.taxpayerName;

    final displayEmail = profile?.email ?? '';
    final displayPhone = profile?.phoneNumber ?? '';

    // State-derived tax office / authority (only shown when state is known)
    final state = profile?.state ?? '';
    final taxOffice = state.isNotEmpty ? _taxOfficeFromState(state) : null;
    final taxAuthority = state.isNotEmpty ? _taxAuthorityFromState(state) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Validated badge row ──────────────────────────────────────
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIN Validated',
                  style: _gs(13, weight: FontWeight.w600, color: Colors.white),
                ),
                Text(
                  'Verified via Joint Tax Board',
                  style: _gs(11, color: Colors.white60),
                ),
              ],
            ),
            const Spacer(),
            // TIN type badge (INDIVIDUAL / BUSINESS)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                result.tinType,
                style: _gs(9, weight: FontWeight.w700, color: Colors.white70),
              ),
            ),
          ],
        ),
        const Gap(18),

        Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
        const Gap(14),

        // ── Data rows ────────────────────────────────────────────────
        _DarkInfoRow(label: 'Full Name', value: fullName),
        _DarkInfoRow(label: 'TIN', value: result.tin),
        if (taxOffice != null)
          _DarkInfoRow(label: 'Tax Office', value: taxOffice),
        if (taxAuthority != null)
          _DarkInfoRow(label: 'Tax Authority', value: taxAuthority),
        if (displayPhone.isNotEmpty)
          _DarkInfoRow(label: 'Phone', value: displayPhone),
        if (displayEmail.isNotEmpty)
          _DarkInfoRow(label: 'Email', value: displayEmail),
      ],
    );
  }

  /// Returns the full tax office name for a Nigerian state.
  static String _taxOfficeFromState(String state) {
    switch (state.trim().toLowerCase()) {
      case 'lagos':
        return 'Lagos State Internal Revenue Service';
      case 'abuja':
      case 'fct':
      case 'federal capital territory':
        return 'FCT Internal Revenue Service';
      case 'rivers':
        return 'Rivers State Internal Revenue Service';
      case 'kano':
        return 'Kano State Internal Revenue Service';
      case 'ogun':
        return 'Ogun State Internal Revenue Service';
      case 'oyo':
        return 'Oyo State Internal Revenue Service';
      case 'delta':
        return 'Delta State Board of Internal Revenue';
      case 'anambra':
        return 'Anambra State Internal Revenue Service';
      case 'imo':
        return 'Imo State Internal Revenue Service';
      case 'enugu':
        return 'Enugu State Revenue Service';
      case 'kwara':
        return 'Kwara State Internal Revenue Service';
      case 'edo':
        return 'Edo State Internal Revenue Service';
      case 'cross river':
        return 'Cross River State Internal Revenue Service';
      case 'akwa ibom':
        return 'Akwa Ibom State Internal Revenue Service';
      case 'abia':
        return 'Abia State Board of Internal Revenue';
      case 'adamawa':
        return 'Adamawa State Internal Revenue Service';
      case 'bauchi':
        return 'Bauchi State Internal Revenue Service';
      case 'bayelsa':
        return 'Bayelsa State Internal Revenue Service';
      case 'benue':
        return 'Benue State Internal Revenue Service';
      case 'borno':
        return 'Borno State Internal Revenue Service';
      case 'ebonyi':
        return 'Ebonyi State Internal Revenue Service';
      case 'ekiti':
        return 'Ekiti State Internal Revenue Service';
      case 'gombe':
        return 'Gombe State Internal Revenue Service';
      case 'jigawa':
        return 'Jigawa State Internal Revenue Service';
      case 'kaduna':
        return 'Kaduna State Internal Revenue Service';
      case 'kebbi':
        return 'Kebbi State Internal Revenue Service';
      case 'kogi':
        return 'Kogi State Internal Revenue Service';
      case 'nasarawa':
        return 'Nasarawa State Internal Revenue Service';
      case 'niger':
        return 'Niger State Internal Revenue Service';
      case 'ondo':
        return 'Ondo State Internal Revenue Service';
      case 'osun':
        return 'Osun State Internal Revenue Service';
      case 'plateau':
        return 'Plateau State Internal Revenue Service';
      case 'sokoto':
        return 'Sokoto State Internal Revenue Service';
      case 'taraba':
        return 'Taraba State Internal Revenue Service';
      case 'yobe':
        return 'Yobe State Internal Revenue Service';
      case 'zamfara':
        return 'Zamfara State Internal Revenue Service';
      case 'katsina':
        return 'Katsina State Internal Revenue Service';
      default:
        final words = state.trim().split(' ').where((w) => w.isNotEmpty);
        final titleCase = words
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join(' ');
        return '$titleCase State Internal Revenue Service';
    }
  }

  /// Returns the short acronym for the tax authority of a Nigerian state.
  static String _taxAuthorityFromState(String state) {
    switch (state.trim().toLowerCase()) {
      case 'lagos':
        return 'LIRS';
      case 'abuja':
      case 'fct':
      case 'federal capital territory':
        return 'FCIRS';
      case 'rivers':
        return 'RIRS';
      case 'kano':
        return 'KIRS';
      case 'ogun':
        return 'OGIRS';
      case 'oyo':
        return 'OYIRS';
      case 'delta':
        return 'DBIR';
      case 'anambra':
        return 'AIRS';
      case 'imo':
        return 'IIRS';
      case 'enugu':
        return 'ESRS';
      case 'kwara':
        return 'KWIRS';
      case 'edo':
        return 'EIRS';
      case 'cross river':
        return 'CRSIRS';
      case 'akwa ibom':
        return 'AKSIRS';
      case 'abia':
        return 'ABIRS';
      case 'adamawa':
        return 'ADIRS';
      case 'bauchi':
        return 'BSIRS';
      case 'bayelsa':
        return 'BYIRS';
      case 'benue':
        return 'BIRS';
      case 'borno':
        return 'BNIRS';
      case 'ebonyi':
        return 'EBIRS';
      case 'ekiti':
        return 'EKIRS';
      case 'gombe':
        return 'GIRS';
      case 'jigawa':
        return 'JIRS';
      case 'kaduna':
        return 'KDIRS';
      case 'kebbi':
        return 'KBIRS';
      case 'kogi':
        return 'KGIRS';
      case 'nasarawa':
        return 'NASIRS';
      case 'niger':
        return 'NIRS';
      case 'ondo':
        return 'ODIRS';
      case 'osun':
        return 'OSIRS';
      case 'plateau':
        return 'PIRS';
      case 'sokoto':
        return 'SIRS';
      case 'taraba':
        return 'TIRS';
      case 'yobe':
        return 'YIRS';
      case 'zamfara':
        return 'ZIRS';
      case 'katsina':
        return 'KTIRS';
      default:
        final words = state.trim().split(' ').where((w) => w.isNotEmpty);
        return words.map((w) => w[0].toUpperCase()).join() + 'IRS';
    }
  }
}

// ── Dark card info row ────────────────────────────────────────────────────────

class _DarkInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DarkInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                color: Colors.white60,
                letterSpacing: 13 * 0.02,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 13 * 0.02,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step badge ────────────────────────────────────────────────────────────────

class _StepBadge extends StatelessWidget {
  final String label;
  const _StepBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
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
}




// // lib/features/tools/presentation/screens/taxation/filing/tin_validation_screen2.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
// import 'package:savvy_bee_mobile/features/tools/data/repositories/tin_validation_repository.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/tin_validation_provider.dart';

// class TinValidationScreen2 extends ConsumerWidget {
//   static const String path = FilingRoutes.tinValidation2;

//   const TinValidationScreen2({super.key});

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
//   Widget build(BuildContext context, WidgetRef ref) {
//     final result = ref.watch(tinValidationResultProvider);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: Text('TIN Validation', style: _gs(16, weight: FontWeight.w600)),
//         centerTitle: false,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Badge ─────────────────────────────────────────────────
//               const _StepBadge(label: 'EXISTING TAXPAYER · TIN LOOKUP'),
//               const Gap(20),

//               // ── Headline ──────────────────────────────────────────────
//               Text(
//                 'Enter your Tax\nIdentification Number',
//                 style: _gs(26, weight: FontWeight.w700),
//               ),
//               const Gap(10),
//               Text(
//                 "We'll verify your TIN with the Joint Tax Board (JTB)\nportal and pull in your tax records automatically.",
//                 style: _gs(13, color: AppColors.greyDark),
//               ),
//               const Gap(24),

//               // ── Validated card ────────────────────────────────────────
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(18),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1A1A1A),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: result == null
//                     ? const Center(
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(vertical: 16),
//                           child: CircularProgressIndicator(
//                             color: _yellow,
//                             strokeWidth: 2,
//                           ),
//                         ),
//                       )
//                     : _ValidatedCardContent(result: result),
//               ),
//               const Gap(16),

//               // ── Success note ──────────────────────────────────────────
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF0FFF4),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: const Color(0xFF43A047).withValues(alpha: 0.35),
//                   ),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Icon(
//                       Icons.check_circle_outline,
//                       size: 15,
//                       color: Color(0xFF2E7D32),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         'Your tax records have been fetched and your return pre-filled. You can review everything before confirming.',
//                         style: _gs(12, color: const Color(0xFF2E7D32)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Spacer(),

//               // ── CTA ───────────────────────────────────────────────────
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: result != null
//                       ? () => context.pushNamed(FilingRoutes.step1)
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _yellow,
//                     disabledBackgroundColor: _yellow.withValues(alpha: 0.35),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     elevation: 0,
//                   ),
//                   child: Text(
//                     'Proceed to filing',
//                     style: _gs(
//                       15,
//                       weight: FontWeight.w600,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Validated card content ────────────────────────────────────────────────────

// class _ValidatedCardContent extends StatelessWidget {
//   final TinValidationResult result;

//   const _ValidatedCardContent({required this.result});

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
//   Widget build(BuildContext context) {
//     // Derive a short tax authority label from the full office name
//     // e.g. "Lagos Internal Revenue Service" → "LIRS"
//     final taxAuthority = _shortAuthority(result.taxOffice);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Validated badge row ──────────────────────────────────────
//         Row(
//           children: [
//             Container(
//               width: 28,
//               height: 28,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF2E7D32),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.check, color: Colors.white, size: 16),
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'TIN Validated',
//                   style: _gs(13, weight: FontWeight.w600, color: Colors.white),
//                 ),
//                 Text(
//                   'Verified via Joint Tax Board',
//                   style: _gs(11, color: Colors.white60),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             // TIN type badge (INDIVIDUAL / BUSINESS)
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: Text(
//                 result.tinType,
//                 style: _gs(9, weight: FontWeight.w700, color: Colors.white70),
//               ),
//             ),
//           ],
//         ),
//         const Gap(18),

//         Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
//         const Gap(14),

//         // ── Data rows ────────────────────────────────────────────────
//         _DarkInfoRow(label: 'Full Name', value: result.taxpayerName),
//         _DarkInfoRow(label: 'TIN', value: result.tin),
//         _DarkInfoRow(label: 'Tax Office', value: result.taxOffice),
//         _DarkInfoRow(label: 'Tax Authority', value: taxAuthority),
//         if (result.address.isNotEmpty)
//           _DarkInfoRow(label: 'Address', value: result.address),
//         if (result.phoneNumber.isNotEmpty)
//           _DarkInfoRow(label: 'Phone', value: result.phoneNumber),
//         if (result.email.isNotEmpty)
//           _DarkInfoRow(label: 'Email', value: result.email),
//       ],
//     );
//   }

//   /// Converts a full tax office name to a short acronym.
//   /// Falls back to the first word if no known acronym matches.
//   String _shortAuthority(String office) {
//     final lower = office.toLowerCase();
//     if (lower.contains('lagos')) return 'LIRS';
//     if (lower.contains('abuja') || lower.contains('fct')) return 'FCIRS';
//     if (lower.contains('rivers')) return 'RIRS';
//     if (lower.contains('kano')) return 'KIRS';
//     if (lower.contains('ogun')) return 'OGIRS';
//     if (lower.contains('federal inland')) return 'NRS';
//     // Generic: take first letter of each word
//     final words = office.split(' ').where((w) => w.isNotEmpty).toList();
//     if (words.length >= 2) {
//       return words.map((w) => w[0].toUpperCase()).join();
//     }
//     return office;
//   }
// }

// // ── Dark card info row ────────────────────────────────────────────────────────

// class _DarkInfoRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _DarkInfoRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 13,
//                 color: Colors.white60,
//                 letterSpacing: 13 * 0.02,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               style: const TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//                 letterSpacing: 13 * 0.02,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Step badge ────────────────────────────────────────────────────────────────

// class _StepBadge extends StatelessWidget {
//   final String label;
//   const _StepBadge({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 8,
//           height: 8,
//           decoration: const BoxDecoration(
//             color: Color(0xFFF5C842),
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: const TextStyle(
//             fontFamily: 'GeneralSans',
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFFF5C842),
//             letterSpacing: 11 * 0.02,
//           ),
//         ),
//       ],
//     );
//   }
// }
