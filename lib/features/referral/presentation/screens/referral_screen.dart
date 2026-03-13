import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:savvy_bee_mobile/core/utils/assets/avatars.dart';
import 'package:savvy_bee_mobile/features/referral/domain/models/referral_model.dart';
import 'package:savvy_bee_mobile/features/referral/presentation/providers/referral_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_loading_widget.dart';
import '../../../../core/widgets/custom_error_widget.dart';

class ReferralScreen extends ConsumerWidget {
  static const String path = '/referrals';
  static const String name = '/referrals';

  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralAsync = ref.watch(referralProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Refer & Earn',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert, color: Colors.black),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: referralAsync.when(
        loading: () => const CustomLoadingWidget(),
        error: (error, stack) => CustomErrorWidget.error(
          subtitle: error.toString(),
          onRetry: () => ref.refresh(referralProvider),
        ),
        data: (data) => _buildContent(context, data),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReferralData data) {
    final referralCode = '@${data.username}';

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Hero banner ──────────────────────────────────────────────────
          _buildHeroBanner(context, data),

          const Gap(20),

          // ── Unique code + Invite Now ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Referral code row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Your Unique Code: ',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: referralCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Referral code copied!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          referralCode,
                          style: const TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(16),

                // Invite Now button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Share.share(
                        'Join me on Savvy Bee! Use my referral code $referralCode to sign up and earn 30 flowers. 🐝🌸',
                        subject: 'Join Savvy Bee!',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5C518),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Invite Now',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(20),

          // ── My Invitees ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Invitees (${data.referrals.length})',
                    style: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Gap(12),
                  if (data.referrals.isEmpty)
                    _buildEmptyState()
                  else
                    ...data.referrals.map(
                      (referral) => _buildReferralItem(referral),
                    ),
                ],
              ),
            ),
          ),

          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, ReferralData data) {
    return Stack(
      children: [
        // Background image
        ClipRRect(
          child: Image.asset(
            'assets/images/referral/referral_bg.png',
            width: double.infinity,
            height: 330,
            fit: BoxFit.fitWidth,
            errorBuilder: (_, __, ___) => Container(
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF87CEEB), Color(0xFF98D4A3)],
                ),
              ),
            ),
          ),
        ),

        // Content overlay
        // SizedBox(
        //   height: 260,
        //   width: double.infinity,
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: [
        //       const Gap(16),
        //       // Big title text
        //       // Padding(
        //       //   padding: const EdgeInsets.symmetric(horizontal: 24),
        //       //   child: Text(
        //       //     'Invite Friends To\nGet 30 Flowers',
        //       //     textAlign: TextAlign.center,
        //       //     style: TextStyle(
        //       //       fontSize: 32,
        //       //       fontWeight: FontWeight.w900,
        //       //       fontFamily: 'GeneralSans',
        //       //       foreground: Paint()
        //       //         ..style = PaintingStyle.stroke
        //       //         ..strokeWidth = 3
        //       //         ..color = const Color(0xFF7B4F00),
        //       //       shadows: const [],
        //       //     ),
        //       //   ),
        //       // ),
        //     ],
        //   ),
        // ),

        // Title text (filled layer on top of stroke)
        SizedBox(
          height: 260,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Gap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Image.asset(
                  'assets/images/referral/referral_txt.png',
                  width: double.infinity,
                  height: 130,
                  // fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 260,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF87CEEB), Color(0xFF98D4A3)],
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(16),

              // Flowers counter pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your Flowers: ',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${data.flower}',
                      style: const TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const Gap(4),
                    Image.asset(
                      'assets/images/other/PINK FLOWER - CURRENCY.png',
                      width: 18,
                      height: 18,
                      errorBuilder: (_, __, ___) =>
                          const Text('🌸', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),

              const Gap(12),

              // Steps row
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStep(
                      icon: Icons.share_outlined,
                      label: 'Share Link',
                      isCircleOutlined: true,
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.black54,
                    ),
                    _buildStep(
                      assetPath: 'assets/images/other/STAR.png',
                      label: 'Invitee Finished Tasks',
                      isYellow: true,
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.black54,
                    ),
                    _buildStep(
                      assetPath:
                          'assets/images/other/PINK FLOWER - CURRENCY.png',
                      label: 'Get Flowers',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    IconData? icon,
    String? assetPath,
    required String label,
    bool isCircleOutlined = false,
    bool isYellow = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isYellow ? const Color(0xFFFFC107) : Colors.white,
            border: isCircleOutlined
                ? Border.all(color: const Color(0xFFE0E0E0), width: 1.5)
                : null,
          ),
          child: Center(
            child: assetPath != null
                ? Image.asset(
                    assetPath,
                    width: 22,
                    height: 22,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.star,
                      size: 22,
                      color: isYellow ? Colors.white : Colors.black54,
                    ),
                  )
                : Icon(icon, size: 22, color: Colors.black54),
          ),
        ),
        const Gap(6),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralItem(Referral referral) {
    final initial = referral.username.isNotEmpty
        ? referral.username[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Avatar circle with initial
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFC107),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              referral.username,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
          // Flowers earned indicator
          Row(
            children: [
              const Text(
                '1000',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const Gap(4),
              Image.asset(
                'assets/images/other/PINK FLOWER - CURRENCY.png',
                width: 16,
                height: 16,
                errorBuilder: (_, __, ___) =>
                    const Text('🌸', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF8E0),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/icons/no_transaction.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.receipt_long_outlined,
                    size: 36,
                    color: Color(0xFFFFC107),
                  ),
                ),
              ),
            ),
            const Gap(12),
            const Text(
              'No Transaction History',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF828383),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
