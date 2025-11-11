import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  static String path = '/premium';

  const PremiumScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(Logos.logoText),
        actions: [
          IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Your one-time offer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38,
              height: 1.0,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          Image.asset(Assets.happyBeesSvg),
          _buildPerksCard(),
          const Gap(24),
          Text(
            'Enjoy one week free then ₦5,000/month',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          Text(
            'billed at ₦50,000/year',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(24),
          CustomElevatedButton(text: 'Start free trial', onPressed: () {}),
          const Gap(12),
          Text(
            "We'll remind you via push notification and email before your trial ends",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              fontFamily: Constants.neulisNeueFontFamily,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: AppColors.primary, size: 24),
        const Gap(8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
              color: AppColors.background,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerksCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerkItem(
            'Premium (Bee+): Access to full AI co-pilot (Nahl) with personalized daily insights, habit tracking, and step by step financial plans',
          ),
          _buildPerkItem(
            'Unlocks the entire financial literacy library (12+ modules) including advanced topics like investing, debt management, taxation etc',
          ),
          // _buildPerkItem(
          //   'Unlock Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do.',
          // ),
        ],
      ),
    );
  }
}
