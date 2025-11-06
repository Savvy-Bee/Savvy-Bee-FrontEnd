import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/fund/new_card_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/mini_share_button.dart';

class FundWithCardScreen extends ConsumerStatefulWidget {
  static String path = '/fund-with-card';

  const FundWithCardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FundWithCardScreenState();
}

class _FundWithCardScreenState extends ConsumerState<FundWithCardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add by card'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: MiniButton(onTap: () {}),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black.withValues(alpha: 0.5)),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(Assets.cardSvg),
          ),
          const Gap(24),
          Text(
            "You'll be charged for adding money with a card",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
          ),
          const Gap(24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saved cards",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: Constants.neulisNeueFontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "You do not have any saved card..",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
          const Gap(24),
          CustomElevatedButton(
            text: 'Add new card',
            onPressed: () => context.pushNamed(NewCardScreen.path),
          ),
        ],
      ),
    );
  }
}
