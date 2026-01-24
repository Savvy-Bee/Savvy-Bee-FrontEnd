import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/select_priority_screen.dart';

import '../../../../core/utils/assets/logos.dart';
import '../../../../core/widgets/icon_text_row_widget.dart';

class ReferralScreen extends ConsumerWidget {
  static const String path = '/referral';

  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double size = MediaQuery.sizeOf(context).width / 1.7;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(Logos.logo, scale: 4.5),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconTextRowWidget(
              'Next',
              AppIcon(AppIcons.arrowRightIcon),
              reverse: true,
              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              onTap: () => context.pushNamed(SelectPriorityScreen.path),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16).copyWith(top: 0),
        physics: const ClampingScrollPhysics(),
        children: [
          Image.asset(Illustrations.savvyCoin, height: size, width: size),
          const Gap(16),
          IntroText(title: 'Refer friends, get 1 year free.'),
          const Gap(8),
          Text(
            'Refer 2 friends to cover 6 months of Savvy Bee. Refer 1 more friend and earn 1 year free',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.1),
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

                  height: 1.1,
                ),
              ),
              const Gap(12),
              Text(subtitle, style: TextStyle(fontSize: 12, height: 1.1)),
            ],
          ),
        ),
      ],
    );
  }
}
