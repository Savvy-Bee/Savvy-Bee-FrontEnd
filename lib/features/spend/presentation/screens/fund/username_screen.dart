import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/copy_text_icon_button.dart';

import '../../../../../core/utils/assets/assets.dart';

class UsernameScreen extends ConsumerWidget {
  static const String path = '/username';
  const UsernameScreen({super.key});

  void _copyUsername(BuildContext context, String username) {
    Clipboard.setData(ClipboardData(text: username));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Username copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareUsername(String username) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Send me money on Savvy Bee using my username: $username',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return homeDataAsync.when(
      loading: () => const Scaffold(body: CustomLoadingWidget()),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Share your username')),
        body: const CustomErrorWidget(subtitle: 'Failed to load username.'),
      ),
      data: (homeData) {
        final username = '@${homeData.data.username}';

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
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                              offset: const Offset(2, 4),
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
                          color: AppColors.background,
                        ),
                      ),
                      const Gap(5),
                      Text(
                        'Receive money from your friends on Bee with your username.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.background,
                        ),
                      ),
                      const Gap(24),
                      _buildUsernameTile(context, username),
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
                            onPressed: () => _shareUsername(username),
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
      },
    );
  }

  Widget _buildUsernameTile(BuildContext context, String username) {
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
              Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          CopyTextIconButton(
            label: 'Copy',
            onPressed: () => _copyUsername(context, username),
          ),
        ],
      ),
    );
  }
}
