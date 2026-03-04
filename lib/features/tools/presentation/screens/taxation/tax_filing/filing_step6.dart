import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

class FilingStep6Screen extends StatelessWidget {
  static const String path = FilingRoutes.step6;

  const FilingStep6Screen({super.key});

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Hero section ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    MediaQuery.of(context).padding.top + 40,
                    24,
                    32,
                  ),
                  child: Column(
                    children: [
                      // Yellow circle with tick
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: _yellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                      const Gap(20),
                      const Text(
                        'Your return is with\nyour partner',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 26 * 0.02,
                          height: 1.2,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        'We\'ll notify you once it\'s validated and submitted — usually within 24–48 hours.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 13,
                          color: AppColors.greyDark,
                          letterSpacing: 13 * 0.02,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Filing progress ───────────────────────────
                      const Text(
                        'Filing Progress',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 16 * 0.02,
                        ),
                      ),
                      const Gap(16),
                      _ProgressTimeline(),
                      const Gap(20),

                      // ── Notification info card ────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            const Icon(
                              Icons.notifications_active_outlined,
                              size: 18,
                              color: Colors.blueAccent,
                            ),
                            Expanded(
                              child: Text(
                                'You\'ll be notified at each stage\n\nPush notification + in-app message when validated and submitted. Final confirmation: "Done. Savvy Bee has filed your 2025 tax return."',
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontSize: 12,
                                  color: Colors.blueAccent.shade700,
                                  letterSpacing: 12 * 0.02,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),

                      // ── Filing record summary ─────────────────────
                      const Text(
                        'Filing Record',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 16 * 0.02,
                        ),
                      ),
                      const Gap(12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            _RecordRow(label: 'Tax year', value: '2025'),
                            _RecordRow(
                              label: 'Filing tier',
                              value: 'Freelancer',
                            ),
                            _RecordRow(label: 'Tax paid', value: '₦118,400'),
                            _RecordRow(label: 'Filing fee', value: '₦20,000'),
                            _RecordRow(
                              label: 'Reference',
                              value: 'SB-2025-AO-0147',
                            ),
                            const Gap(12),
                            // Download button
                            OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: const Color(0xFF43A047),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(
                                Icons.download_outlined,
                                size: 16,
                                color: Color(0xFF43A047),
                              ),
                              label: const Text(
                                'Download proof of filing',
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF43A047),
                                  letterSpacing: 13 * 0.02,
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
              ],
            ),
          ),

          // ── CTA button ──────────────────────────────────────────────
          BottomActionButton(
            label: 'View my filing record',
            onTap: () => context.pushNamed(FilingRoutes.filingRecord),
          ),
        ],
      ),
    );
  }
}

// ── Progress timeline ─────────────────────────────────────────────────────────

class _ProgressTimeline extends StatelessWidget {
  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineStep(
          label: 'Reviewed',
          sublabel: 'Return confirmed by you',
          status: _StepStatus.done,
          isLast: false,
        ),
        _TimelineStep(
          label: 'Validated',
          sublabel: 'Partner reviewing — 24–48 hrs',
          status: _StepStatus.inProgress,
          badge: 'IN PROGRESS',
          isLast: false,
        ),
        _TimelineStep(
          label: 'Submitted',
          sublabel: 'Filed with FIRS',
          status: _StepStatus.pending,
          isLast: true,
        ),
      ],
    );
  }
}

enum _StepStatus { done, inProgress, pending }

class _TimelineStep extends StatelessWidget {
  final String label;
  final String sublabel;
  final _StepStatus status;
  final String? badge;
  final bool isLast;

  const _TimelineStep({
    required this.label,
    required this.sublabel,
    required this.status,
    this.badge,
    required this.isLast,
  });

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Indicator + line ───────────────────────────────────────
        SizedBox(
          width: 32,
          child: Column(
            children: [
              _buildIndicator(),
              if (!isLast)
                Container(
                  width: 2,
                  height: 48,
                  color: status == _StepStatus.done
                      ? Colors.black87
                      : AppColors.borderLight,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: status == _StepStatus.pending
                              ? AppColors.grey
                              : Colors.black87,
                          letterSpacing: 14 * 0.02,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        sublabel,
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

  Widget _buildIndicator() {
    switch (status) {
      case _StepStatus.done:
        return Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 14),
        );
      case _StepStatus.inProgress:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _yellow, width: 2.5),
            color: Colors.white,
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: _yellow,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case _StepStatus.pending:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight, width: 2),
            color: Colors.white,
          ),
        );
    }
  }
}

// ── Record row ────────────────────────────────────────────────────────────────

class _RecordRow extends StatelessWidget {
  final String label;
  final String value;

  const _RecordRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 13 * 0.02,
            ),
          ),
        ],
      ),
    );
  }
}
