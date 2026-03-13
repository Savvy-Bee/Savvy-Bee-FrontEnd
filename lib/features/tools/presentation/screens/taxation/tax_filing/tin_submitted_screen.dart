// lib/features/tools/presentation/screens/taxation/filing/tin_submitted_screen.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/taxation/taxation_dashboard_screen.dart';

class TinSubmittedScreen extends StatelessWidget {
  static const String path = FilingRoutes.tinSubmitted;

  const TinSubmittedScreen({super.key});

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
    final today = DateTime.now();
    final dateStr =
        '${_weekday(today.weekday)}, ${_month(today.month)} ${today.day} ${today.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                children: [
                  // ── Yellow clock icon ────────────────────────────────────
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _yellow, width: 2.5),
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.access_time,
                        size: 34,
                        color: Color(0xFFF5C842),
                      ),
                    ),
                  ),
                  const Gap(24),

                  // ── Headline ───────────────────────────────────────────────
                  Center(
                    child: Text(
                      'Registration submitted!',
                      style: _gs(24, weight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(10),
                  Center(
                    child: Text(
                      'Your information has been sent to NRS for\nTIN generation. We\'ll notify you as soon\nas your TIN is ready.',
                      style: _gs(13, color: AppColors.greyDark),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(28),

                  // ── Registration Status card ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registration Status',
                          style: _gs(14, weight: FontWeight.w600),
                        ),
                        const Gap(16),

                        // ── Step 1: submitted ─────────────────────────────
                        _TimelineStep(
                          icon: Icons.check,
                          iconBg: Colors.black87,
                          iconColor: Colors.white,
                          label: 'Registration submitted',
                          sublabel: dateStr,
                          lineColor: Colors.black87,
                          isLast: false,
                        ),

                        // ── Step 2: identity verification in progress ──────
                        _TimelineStep(
                          icon: Icons.circle,
                          iconBg: Colors.white,
                          iconColor: _yellow,
                          outlined: true,
                          label: 'Identity verification',
                          sublabel: 'In progress — 24–48 hrs',
                          badge: 'IN PROGRESS',
                          lineColor: const Color(0xFFEEEEEE),
                          isLast: false,
                        ),

                        // ── Step 3: TIN issued ────────────────────────────
                        _TimelineStep(
                          icon: Icons.circle,
                          iconBg: const Color(0xFFEEEEEE),
                          iconColor: const Color(0xFFEEEEEE),
                          label: 'TIN issued by NRS',
                          sublabel: 'Pending approval',
                          lineColor: const Color(0xFFEEEEEE),
                          isLast: false,
                        ),

                        // ── Step 4: filing unlocked ───────────────────────
                        _TimelineStep(
                          icon: Icons.circle,
                          iconBg: const Color(0xFFEEEEEE),
                          iconColor: const Color(0xFFEEEEEE),
                          label: 'Filing unlocked',
                          sublabel: 'After TIN issuance',
                          lineColor: Colors.transparent,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),

                  // ── Notification note ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDDE3FF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          size: 18,
                          color: Color(0xFF5B6BDD),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "We'll notify you immediately",
                                style: _gs(
                                  13,
                                  weight: FontWeight.w600,
                                  color: const Color(0xFF3A4AC7),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Push notification + in-app message the moment your TIN is issued. You can then proceed to file your taxes.',
                                style: _gs(12, color: const Color(0xFF5B6BDD)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),

                  // ── What happens next ─────────────────────────────────────
                  Text(
                    'What happens next',
                    style: _gs(15, weight: FontWeight.w600),
                  ),
                  const Gap(14),

                  _NextStep(
                    icon: Icons.search,
                    text:
                        'NRS verifies your BVN and NIN against national databases',
                  ),
                  const Gap(10),
                  _NextStep(
                    icon: Icons.article_outlined,
                    text:
                        'Your TIN is generated and linked to your tax profile',
                  ),
                  const Gap(10),
                  _NextStep(
                    icon: Icons.lock_open_outlined,
                    text: 'Savvy Bee unlocks your filing flow automatically',
                  ),
                  const Gap(28),

                  // ── Preview filing flow button ─────────────────────────────
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton.icon(
                  //     onPressed: () => context.pushNamed(FilingRoutes.step1),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: _yellow,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(50),
                  //       ),
                  //       padding: const EdgeInsets.symmetric(vertical: 16),
                  //       elevation: 0,
                  //     ),
                  //     icon: const SizedBox.shrink(),
                  //     label: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Text(
                  //           'Preview filing flow',
                  //           style: _gs(
                  //             15,
                  //             weight: FontWeight.w600,
                  //             color: Colors.black,
                  //           ),
                  //         ),
                  //         const SizedBox(width: 6),
                  //         const Icon(
                  //           Icons.chevron_right,
                  //           size: 18,
                  //           color: Colors.black,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const Gap(12),

                  // ── Back to home link ─────────────────────────────────────
                  Center(
                    child: TextButton.icon(
                      onPressed: () =>
                          context.pushNamed(TaxationDashboardScreen.path),
                      icon: const Icon(
                        Icons.home_outlined,
                        size: 16,
                        color: Colors.black54,
                      ),
                      label: Text(
                        'Back to home',
                        style: _gs(13, color: Colors.black54),
                      ),
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekday(int w) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[w - 1];
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}

// ── Timeline step ─────────────────────────────────────────────────────────────

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool outlined;
  final String label;
  final String sublabel;
  final String? badge;
  final Color lineColor;
  final bool isLast;

  static const _yellow = Color(0xFFF5C842);

  const _TimelineStep({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.outlined = false,
    required this.label,
    required this.sublabel,
    this.badge,
    required this.lineColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Indicator + line ───────────────────────────────────────────────
        SizedBox(
          width: 28,
          child: Column(
            children: [
              // Dot
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: outlined ? Colors.white : iconBg,
                  shape: BoxShape.circle,
                  border: outlined
                      ? Border.all(color: _yellow, width: 2.5)
                      : null,
                ),
                child: outlined
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: _yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : Icon(icon, size: 14, color: iconColor),
              ),
              if (!isLast) Container(width: 2, height: 44, color: lineColor),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // ── Text ───────────────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 13 * 0.02,
                        ),
                      ),
                      Text(
                        sublabel,
                        style: const TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 11,
                          color: Color(0xFF888888),
                          letterSpacing: 11 * 0.02,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 8,
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
          ),
        ),
      ],
    );
  }
}

// ── What happens next row ─────────────────────────────────────────────────────

class _NextStep extends StatelessWidget {
  final IconData icon;
  final String text;

  const _NextStep({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.black54),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                color: Colors.black87,
                letterSpacing: 13 * 0.02,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
