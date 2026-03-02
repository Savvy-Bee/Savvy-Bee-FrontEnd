import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

/// Shows a bottom sheet explaining data usage.
/// Returns `true` if user agreed, `false` if declined, `null` if dismissed.
Future<bool?> showNahlConsentDialog(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isDismissible: false,
    enableDrag: true,
    isScrollControlled: true,             // ← crucial
    backgroundColor: Colors.transparent,
    builder: (context) => const _NahlConsentSheet(),
  );
}

class _NahlConsentSheet extends StatelessWidget {
  const _NahlConsentSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,                        // don't force full screen
      initialChildSize: 0.60,               // start around 60%
      minChildSize: 0.50,                   // min ~50%
      maxChildSize: 0.90,                   // max ~90%
      snap: true,                           // nice snap behavior
      snapSizes: const [0.50, 0.75, 0.90],  // optional – feel free to adjust
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,  // ← important!
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon + Title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.privacy_tip_outlined,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Before you chat with Nahl',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'GeneralSans',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Explanation text
                        const Text(
                          'To give you AI-powered responses, Nahl Chat shares data with a third-party AI provider (OpenAI).',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'GeneralSans',
                            color: Color(0xFF444444),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _bulletRow(
                          Icons.chat_bubble_outline,
                          'What is shared',
                          'Your chat messages and any images you upload.',
                        ),
                        const SizedBox(height: 12),
                        _bulletRow(
                          Icons.send_outlined,
                          'Who receives it',
                          'OpenAI — used solely to generate your AI responses.',
                        ),
                        const SizedBox(height: 12),
                        _bulletRow(
                          Icons.auto_awesome_outlined,
                          'Why it is shared',
                          'Without this, Nahl cannot understand or reply to your messages.',
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFF0F0F0), height: 32),

                        const Text(
                          'By tapping Agree you confirm you are happy for your messages and images to be processed by OpenAI on Nahl\'s behalf.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'GeneralSans',
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Buttons (stick to bottom of scroll view)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Agree',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Decline',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'GeneralSans',
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24), // extra bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bulletRow(IconData icon, String label, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'GeneralSans',
                color: Color(0xFF222222),
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

// /// Shows a bottom sheet explaining data usage.
// /// Returns `true` if user agreed, `false` if declined, `null` if dismissed.
// Future<bool?> showNahlConsentDialog(BuildContext context) {
//   return showModalBottomSheet<bool>(
//     context: context,
//     isDismissible: false, // User must make an explicit choice
//     enableDrag: false,
//     backgroundColor: Colors.transparent,
//     builder: (_) => const _NahlConsentSheet(),
//   );
// }

// class _NahlConsentSheet extends StatelessWidget {
//   const _NahlConsentSheet();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       padding: const EdgeInsets.fromLTRB(24, 20, 24, 36), 
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Handle bar ─────────────────────────────────────────────
//           Center(
//             child: Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(bottom: 20),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),

//           // ── Icon + Title ────────────────────────────────────────────
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.privacy_tip_outlined,
//                   color: AppColors.primary,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Text(
//                   'Before you chat with Nahl',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'GeneralSans',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           // ── Data usage explanation ──────────────────────────────────
//           const Text(
//             'To give you AI-powered responses, Nahl Chat shares data with a third-party AI provider (OpenAI).',
//             style: TextStyle(
//               fontSize: 14,
//               fontFamily: 'GeneralSans',
//               color: Color(0xFF444444),
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 16),

//           _bulletRow(
//             Icons.chat_bubble_outline,
//             'What is shared',
//             'Your chat messages and any images you upload.',
//           ),
//           const SizedBox(height: 12),
//           _bulletRow(
//             Icons.send_outlined,
//             'Who receives it',
//             'OpenAI — used solely to generate your AI responses.',
//           ),
//           const SizedBox(height: 12),
//           _bulletRow(
//             Icons.auto_awesome_outlined,
//             'Why it is shared',
//             'Without this, Nahl cannot understand or reply to your messages.',
//           ),

//           const SizedBox(height: 8),
//           Divider(color: Colors.grey.shade200, height: 32),

//           const Text(
//             'By tapping Agree you confirm you are happy for your messages and images to be processed by OpenAI on Nahl\'s behalf.',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//               fontFamily: 'GeneralSans',
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 24),

//           // ── Buttons ─────────────────────────────────────────────────
//           SizedBox(
//             width: double.infinity,
//             child: FilledButton(
//               style: FilledButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text(
//                 'Agree',
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'GeneralSans',
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 side: BorderSide(color: Colors.grey.shade300),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text(
//                 'Decline',
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontFamily: 'GeneralSans',
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _bulletRow(IconData icon, String label, String description) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 18, color: AppColors.primary),
//         const SizedBox(width: 10),
//         Expanded(
//           child: RichText(
//             text: TextSpan(
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontFamily: 'GeneralSans',
//                 color: Color(0xFF222222),
//                 height: 1.4,
//               ),
//               children: [
//                 TextSpan(
//                   text: '$label: ',
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 TextSpan(text: description),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
