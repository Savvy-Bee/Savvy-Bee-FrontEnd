import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/text_icon_button.dart';

import '../../../../core/utils/assets/logos.dart';

class ReferralScreen extends ConsumerWidget {
  static String path = '/referral';

  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double size = MediaQuery.sizeOf(context).width / 1.5;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(Logos.logo),
        actions: [TextIconButton(text: 'Next', onTap: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.asset(Illustrations.savvyCoin, height: size, width: size),
          Text(
            'Refer friends, get 1 year free.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
              height: 1.1,
            ),
          ),
          const Gap(8),
          Text(
            'Refer 2 friends to cover 6 months of Savvy Bee. Refer 1 more friend and earn 1 year free',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
              height: 1.1,
            ),
          ),
          const Gap(24),
          _buildPerkItem(
            '1',
            'Refer friends, get 1 year free.',
            'Refer 2 friends to cover 6 months of Savvy Bee. Refer 1 more friend and earn 1 year free',
          ),
          const Gap(24),
          _buildPerkItem(
            '2',
            '₦15,000 for your second referal',
            'Get ₦15,000 towards your membership when your 2nd friend becomes an annual member',
          ),
          const Gap(24),
          _buildPerkItem(
            '3',
            'Unlock your 1-year membership',
            'Earn free 1-year access when your 3rd friend becomes an annual member',
          ),
          const Gap(20),
          CustomOutlinedButton(
            text: 'Copy your unique link',
            icon: AppIcon(AppIcons.copyIcon),
            onPressed: () {},
          ),
          const Gap(8),
          CustomElevatedButton(
            text: 'Invite friends',
            buttonColor: CustomButtonColor.black,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPerkItem(String number, String title, String subtitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                  height: 1.1,
                ),
              ),
              const Gap(16),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: Constants.neulisNeueFontFamily,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
