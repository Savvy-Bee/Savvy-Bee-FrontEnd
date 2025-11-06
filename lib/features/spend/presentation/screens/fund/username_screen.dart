import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/copy_text_icon_button.dart';

import '../../../../../core/utils/assets/assets.dart';

class UsernameScreen extends ConsumerWidget {
  static const String path = '/username';
  const UsernameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String username = '@dracarys.babe';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Share your username',
          style: TextStyle(color: AppColors.background),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.background,
      ),
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.shareUsernameBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Gap(16),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.greyDark,
                      border: Border.all(color: AppColors.border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary,
                          offset: Offset(2, 4),
                          blurRadius: 4,
                        ),
                      ],
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(Illustrations.susuAvatar),
                  ),
                  const Gap(24),
                  Text(
                    'Hi, $username!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.neulisNeueFontFamily,
                      color: AppColors.background,
                    ),
                  ),
                  const Gap(5),
                  Text(
                    'Receive money from your friends on Bee with your username.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: Constants.neulisNeueFontFamily,
                      color: AppColors.background,
                    ),
                  ),
                  const Gap(24),
                  _buildUsernameTile(username),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        text: 'Done',
                        buttonColor: CustomButtonColor.white,
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: CustomElevatedButton(
                        text: 'Share',
                        onPressed: () {},
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

  Widget _buildUsernameTile(String username) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your username', style: TextStyle(fontSize: 10)),
              Text(
                username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ],
          ),
          Row(mainAxisSize: MainAxisSize.min, children: []),
          CopyTextIconButton(textToCopy: username),
        ],
      ),
    );
  }
}
