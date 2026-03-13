// lib/features/tools/presentation/screens/taxation/filing/taxpayer_id_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';

class TaxpayerIdScreen extends StatefulWidget {
  static const String path = FilingRoutes.taxpayerId;

  const TaxpayerIdScreen({super.key});

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
  State<TaxpayerIdScreen> createState() => _TaxpayerIdScreenState();
}

class _TaxpayerIdScreenState extends State<TaxpayerIdScreen> {
  /// Shows the NRS redirect confirmation sheet, then opens the WebView.
  /// When the WebView is closed the user lands back here automatically.
  void _onFirstTimeFiler() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.75,
        expand: false,
        builder: (_, scrollController) => _NrsRedirectSheet(
          scrollController: scrollController,
          onContinue: () async {
            Navigator.pop(sheetCtx);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NrsTinWebViewScreen(),
              ),
            );
          },
          onCancel: () => Navigator.pop(sheetCtx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'Taxpayer ID',
          style: TaxpayerIdScreen._gs(16, weight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Step badge ────────────────────────────────────────────
              _StepBadge(label: 'STEP 1 · TAXPAYER IDENTIFICATION'),
              const Gap(18),

              // ── Headline ──────────────────────────────────────────────
              Text(
                'Have you filed taxes\nbefore?',
                style: TaxpayerIdScreen._gs(26, weight: FontWeight.w700),
              ),
              const Gap(10),
              Text(
                'This helps us get you to the right place — whether\nyou already have a TIN or you\'re registering for the\nfirst time.',
                style: TaxpayerIdScreen._gs(13, color: AppColors.greyDark),
              ),
              const Gap(24),

              // ── Option 1: Yes, I have a TIN ──────────────────────────
              _OptionTile(
                icon: Icons.person_outline,
                filled: true,
                title: 'Yes, I have a TIN',
                subtitle:
                    'Existing taxpayer — I\'ll validate my\nTax Identification Number',
                onTap: () => context.pushNamed(FilingRoutes.tinValidation1),
              ),
              const Gap(12),

              // ── Option 2: No, first time ──────────────────────────────
              _OptionTile(
                icon: Icons.person_add_outlined,
                filled: false,
                title: 'No, I\'m filing for the\nfirst time',
                subtitle:
                    'New taxpayer — I\'ll register to get\nmy TIN from NRS',
                onTap: _onFirstTimeFiler,
              ),
              const Gap(20),

              // ── Info note ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBE6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE58F)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.info_outline,
                        size: 15,
                        color: Color(0xFF856404),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A Tax Identification Number (TIN) is required by NRS for all Nigerian taxpayers. If you\'re unsure, check your payslip or contact your employer\'s HR department.',
                        style: TaxpayerIdScreen._gs(
                          12,
                          color: const Color(0xFF856404),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── JTB badge ─────────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Powered by JTB Portal',
                      style: TaxpayerIdScreen._gs(
                        12,
                        color: AppColors.greyDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'JTB',
                        style: TaxpayerIdScreen._gs(
                          11,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── NRS redirect bottom sheet ─────────────────────────────────────────────────

class _NrsRedirectSheet extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onCancel;
  final ScrollController scrollController;

  const _NrsRedirectSheet({
    required this.onContinue,
    required this.onCancel,
    required this.scrollController,
  });

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
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ───────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Icon ──────────────────────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.open_in_browser_outlined,
                color: _yellow,
                size: 24,
              ),
            ),
            const Gap(18),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              'Get your TIN from NRS',
              style: _gs(20, weight: FontWeight.w700),
            ),
            const Gap(10),

            // ── Body ──────────────────────────────────────────────────────
            Text(
              'You\'ll be taken to the Nigeria Revenue Service (NRS) portal to register and obtain your Tax Identification Number.',
              style: _gs(13, color: const Color(0xFF555555)),
            ),
            const Gap(16),

            // ── Steps ─────────────────────────────────────────────────────
            _StepRow(
              number: '1',
              text: 'Complete your TIN registration on the NRS portal.',
            ),
            const Gap(10),
            _StepRow(
              number: '2',
              text: 'Copy your new TIN once it\'s issued.',
            ),
            const Gap(10),
            _StepRow(
              number: '3',
              text:
                  'Close the portal — you\'ll return here and can proceed with "Yes, I have a TIN".',
            ),
            const Gap(28),

            // ── CTA ───────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(
                  'Continue to NRS Portal',
                  style: _gs(15, weight: FontWeight.w600, color: Colors.black),
                ),
              ),
            ),
            const Gap(12),

            // ── Cancel ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: _gs(
                    15,
                    weight: FontWeight.w500,
                    color: const Color(0xFF888888),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Numbered step row ─────────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  final String number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFF5C842).withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF856404),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              color: Color(0xFF444444),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ── NRS WebView screen ────────────────────────────────────────────────────────

class NrsTinWebViewScreen extends StatefulWidget {
  const NrsTinWebViewScreen({super.key});

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
  State<NrsTinWebViewScreen> createState() => _NrsTinWebViewScreenState();
}

class _NrsTinWebViewScreenState extends State<NrsTinWebViewScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;

  static const _nrsUrl = 'https://taxid.nrs.gov.ng/';

  final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    // Sends a real Chrome user-agent so the site doesn't block the request
    userAgent:
        'Mozilla/5.0 (Linux; Android 13; Pixel 7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/124.0.0.0 Mobile Safari/537.36',
    // Required for the NRS site to render correctly
    domStorageEnabled: true,
    databaseEnabled: true,
    cacheEnabled: true,
    // iOS: allow inline media
    allowsInlineMediaPlayback: true,
  );

  void _reload() {
    setState(() { _hasError = false; _isLoading = true; });
    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_nrsUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Back to app',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NRS TIN Registration',
          style: NrsTinWebViewScreen._gs(16, weight: FontWeight.w600),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(_nrsUrl),
              headers: {
                'Accept':
                    'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.9',
              },
            ),
            initialSettings: _settings,
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (_, __) {
              if (mounted) setState(() { _isLoading = true; _hasError = false; });
            },
            onLoadStop: (_, __) {
              if (mounted) setState(() => _isLoading = false);
            },
            onReceivedError: (_, request, error) {
              debugPrint('NRS error [main=${request.isForMainFrame}]: ${error.description}');
              if (request.isForMainFrame!) {
                if (mounted) setState(() { _isLoading = false; _hasError = true; });
              }
            },
            // ── SSL bypass for Android + iOS ──────────────────────────
            // The NRS government portal has a certificate chain not in
            // Android/iOS system trust stores. We proceed only for the
            // known NRS domain; all other SSL errors are rejected.
            onReceivedServerTrustAuthRequest: (_, challenge) async {
              final host = challenge.protectionSpace.host;
              if (host.contains('nrs.gov.ng')) {
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              }
              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.CANCEL,
              );
            },
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          if (_hasError && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_outlined,
                      size: 48,
                      color: Colors.black38,
                    ),
                    const Gap(16),
                    Text(
                      'Could not load the NRS portal',
                      style: NrsTinWebViewScreen._gs(
                        16,
                        weight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),
                    Text(
                      'Check your internet connection and try again.',
                      style: NrsTinWebViewScreen._gs(
                        13,
                        color: const Color(0xFF888888),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(24),
                    ElevatedButton(
                      onPressed: _reload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5C842),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 32,
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: NrsTinWebViewScreen._gs(
                          14,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Option tile ───────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.filled,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                filled ? const Color(0xFF1A1A1A) : const Color(0xFFE5E5E5),
          ),
        ),
        child: Row(
          children: [
            // ── Icon circle ──────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: filled
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: filled ? _yellow : Colors.black54,
              ),
            ),
            const SizedBox(width: 14),

            // ── Text ──────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _gs(
                      14,
                      weight: FontWeight.w600,
                      color: filled ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Gap(3),
                  Text(
                    subtitle,
                    style: _gs(
                      12,
                      color: filled
                          ? Colors.white60
                          : const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: filled ? Colors.white54 : const Color(0xFFAAAAAA),
              size: 20,
            ),
          ],
        ),
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






// // lib/features/tools/presentation/screens/taxation/filing/taxpayer_id_screen.dart

// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
// import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';


// class TaxpayerIdScreen extends StatefulWidget {
//   static const String path = FilingRoutes.taxpayerId;

//   const TaxpayerIdScreen({super.key});

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
//   State<TaxpayerIdScreen> createState() => _TaxpayerIdScreenState();
// }

// class _TaxpayerIdScreenState extends State<TaxpayerIdScreen> {
//    void _onRemindLater() {
//     AppNotification.show(
//       context,
//       message: "Coming soon.",
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: Text('Taxpayer ID', style: TaxpayerIdScreen._gs(16, weight: FontWeight.w600)),
//         centerTitle: false,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//       ),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Step badge ────────────────────────────────────────────
//               _StepBadge(label: 'STEP 1 · TAXPAYER IDENTIFICATION'),
//               const Gap(18),

//               // ── Headline ──────────────────────────────────────────────
//               Text(
//                 'Have you filed taxes\nbefore?',
//                 style: TaxpayerIdScreen._gs(26, weight: FontWeight.w700),
//               ),
//               const Gap(10),
//               Text(
//                 'This helps us get you to the right place — whether\nyou already have a TIN or you\'re registering for the\nfirst time.',
//                 style: TaxpayerIdScreen._gs(13, color: AppColors.greyDark),
//               ),
//               const Gap(24),

//               // ── Option 1: Yes, I have a TIN ──────────────────────────
//               _OptionTile(
//                 icon: Icons.person_outline,
//                 filled: true,
//                 title: 'Yes, I have a TIN',
//                 subtitle:
//                     'Existing taxpayer — I\'ll validate my\nTax Identification Number',
//                 onTap: () => context.pushNamed(FilingRoutes.tinValidation1),
//               ),
//               const Gap(12),

//               // ── Option 2: No, first time ──────────────────────────────
//               _OptionTile(
//                 icon: Icons.person_add_outlined,
//                 filled: false,
//                 title: 'No, I\'m filing for the\nfirst time',
//                 subtitle:
//                     'New taxpayer — I\'ll register to get\nmy TIN from NRS',
//                 // onTap: () => context.pushNamed(FilingRoutes.tinReg1),
//                 onTap: () => _onRemindLater(),
//               ),
//               const Gap(20),

//               // ── Info note ─────────────────────────────────────────────
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFFBE6),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFFFE58F)),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.only(top: 1),
//                       child: Icon(
//                         Icons.info_outline,
//                         size: 15,
//                         color: Color(0xFF856404),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         'A Tax Identification Number (TIN) is required by NRS for all Nigerian taxpayers. If you\'re unsure, check your payslip or contact your employer\'s HR department.',
//                         style: TaxpayerIdScreen._gs(12, color: const Color(0xFF856404)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Spacer(),

//               // ── JTB badge ─────────────────────────────────────────────
//               Center(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Powered by JTB Portal',
//                       style: TaxpayerIdScreen._gs(12, color: AppColors.greyDark),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 4,
//                         horizontal: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF1A1A1A),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         'JTB',
//                         style: TaxpayerIdScreen._gs(
//                           11,
//                           weight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Option tile ───────────────────────────────────────────────────────────────

// class _OptionTile extends StatelessWidget {
//   final IconData icon;
//   final bool filled;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   const _OptionTile({
//     required this.icon,
//     required this.filled,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });

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
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: filled ? const Color(0xFF1A1A1A) : Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: filled ? const Color(0xFF1A1A1A) : const Color(0xFFE5E5E5),
//           ),
//         ),
//         child: Row(
//           children: [
//             // ── Icon circle ──────────────────────────────────────────────
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: filled
//                     ? Colors.white.withValues(alpha: 0.12)
//                     : const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 icon,
//                 size: 22,
//                 color: filled ? _yellow : Colors.black54,
//               ),
//             ),
//             const SizedBox(width: 14),

//             // ── Text ──────────────────────────────────────────────────────
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: _gs(
//                       14,
//                       weight: FontWeight.w600,
//                       color: filled ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   const Gap(3),
//                   Text(
//                     subtitle,
//                     style: _gs(
//                       12,
//                       color: filled ? Colors.white60 : const Color(0xFF888888),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Icon(
//               Icons.chevron_right,
//               color: filled ? Colors.white54 : const Color(0xFFAAAAAA),
//               size: 20,
//             ),
//           ],
//         ),
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
