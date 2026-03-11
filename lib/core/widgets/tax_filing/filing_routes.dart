// lib/core/widgets/tax_filing/filing_routes.dart

/// Central place for all filing-flow route path constants.
/// Register every entry in your GoRouter configuration.
abstract class FilingRoutes {
  FilingRoutes._();

  // ── TIN entry ─────────────────────────────────────────────────────────────
  static const taxpayerId     = '/filing/taxpayer-id';
  static const tinValidation1 = '/filing/tin-validation-1';
  static const tinValidation2 = '/filing/tin-validation-2';

  // ── TIN Registration — Screen 1 (shared classification) ──────────────────
  static const tinReg1 = '/filing/tin-reg-1';

  // ── Personal path — Screens 2-5 ──────────────────────────────────────────
  static const tinRegPersonal2 = '/filing/tin-reg-personal-2'; // identity
  static const tinRegPersonal3 = '/filing/tin-reg-personal-3'; // contact
  static const tinRegPersonal4 = '/filing/tin-reg-personal-4'; // filing details
  static const tinRegPersonal5 = '/filing/tin-reg-personal-5'; // OTP

  // ── Business path — Screens 2-5 ──────────────────────────────────────────
  static const tinRegBusiness2 = '/filing/tin-reg-business-2'; // identity
  static const tinRegBusiness3 = '/filing/tin-reg-business-3'; // contact
  static const tinRegBusiness4 = '/filing/tin-reg-business-4'; // filing details
  static const tinRegBusiness5 = '/filing/tin-reg-business-5'; // OTP

  // ── Shared submitted screen ───────────────────────────────────────────────
  static const tinSubmitted = '/filing/tin-submitted';

  // Legacy aliases so existing code that references tinReg2/tinReg3 still compiles
  static const tinReg2 = tinRegPersonal2;
  static const tinReg3 = tinRegPersonal3;

  // ── Filing steps (unchanged) ──────────────────────────────────────────────
  static const step1        = '/filing/step-1';
  static const step2        = '/filing/step-2';
  static const step3        = '/filing/step-3';
  static const step4        = '/filing/step-4';
  static const step5        = '/filing/step-5';
  static const step6        = '/filing/step-6';
  static const filingRecord = '/filing/record';
  static const String filingDetails = '/filing/details/:id';
}



// // lib/core/widgets/tax_filing/filing_routes.dart

// /// Central place for all filing-flow route path constants.
// /// Register every entry in your GoRouter configuration.
// abstract class FilingRoutes {
//   FilingRoutes._();

//   // ── TIN entry flow (NEW) ──────────────────────────────────────────────────
//   static const taxpayerId      = '/filing/taxpayer-id';
//   static const tinValidation1  = '/filing/tin-validation-1';
//   static const tinValidation2  = '/filing/tin-validation-2';
//   static const tinReg1         = '/filing/tin-reg-1';
//   static const tinReg2         = '/filing/tin-reg-2';
//   static const tinReg3         = '/filing/tin-reg-3';
//   static const tinSubmitted    = '/filing/tin-submitted';

//   // ── Filing steps (EXISTING — unchanged) ──────────────────────────────────
//   static const step1        = '/filing/step-1';
//   static const step2        = '/filing/step-2';
//   static const step3        = '/filing/step-3';
//   static const step4        = '/filing/step-4';
//   static const step5        = '/filing/step-5';
//   static const step6        = '/filing/step-6';
//   static const filingRecord = '/filing/record';
// }


// // /// Central place for all filing-flow route path constants.
// // /// Register each of these inside your GoRouter configuration.
// // abstract class FilingRoutes {
// //   FilingRoutes._();

// //   static const step1 = '/filing/step-1';
// //   static const step2 = '/filing/step-2';
// //   static const step3 = '/filing/step-3';
// //   static const step4 = '/filing/step-4';
// //   static const step5 = '/filing/step-5';
// //   static const step6 = '/filing/step-6';
// //   static const filingRecord = '/filing/record';
// // }