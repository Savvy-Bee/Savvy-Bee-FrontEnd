import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/live_photo_screen.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/info_widget.dart';
import '../../../../../core/widgets/icon_text_row_widget.dart';

class PhotoVerificationScreen extends ConsumerWidget {
  static String path = '/photo-verification';

  const PhotoVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Photo')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoWidget(
                  title: 'Take a quick selfie',
                  subtitle:
                      'We need a clear photo of you to make sure it matches your NIN/BVN records.',
                  icon: SvgPicture.asset(Assets.facialRecogSvg),
                ),
                const Gap(16.0),
                Column(
                  children: [
                    IconTextRowWidget(
                      'Find a bright area',
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const Gap(8.0),
                    IconTextRowWidget(
                      'Remove face coverings',
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const Gap(8.0),
                    IconTextRowWidget(
                      'Look straight at the camera',
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            CustomElevatedButton(
              text: 'Ready',
              onPressed: () {
                context.pushNamed(LivePhotoScreen.path);
              },
              buttonColor: CustomButtonColor.black,
              showArrow: true,
            ),
          ],
        ),
      ),
    );
  }
}
