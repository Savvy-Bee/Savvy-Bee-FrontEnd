import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/avatars.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/url_utils.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';

import '../../../home/presentation/providers/home_data_provider.dart';

class AccountInfoScreen extends ConsumerStatefulWidget {
  static const String path = '/account-info';

  const AccountInfoScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AccountInfoScreenState();
}

class _AccountInfoScreenState extends ConsumerState<AccountInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account Info')),
      body: homeDataAsync.when(
        data: (data) {
          final user = data.data;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          Avatars.luna5,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const Gap(16),
                      GameCard(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRowItem(
                              'Name',
                              '${user.firstName} ${user.lastName}',
                            ),
                            const Divider(height: 0),
                            _buildRowItem('Email', user.email),
                            const Divider(height: 0),
                            _buildRowItem('Date of birth', user.dob),
                            const Divider(height: 0),
                            _buildRowItem('Country of residence', user.country),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => CustomErrorWidget.error(
          subtitle: error.toString(),
          onRetry: () => ref.refresh(homeDataProvider),
        ),
        loading: () => CustomLoadingWidget(),
      ),
      bottomNavigationBar: homeDataAsync.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              CustomElevatedButton(text: 'Edit Account Info', onPressed: () {}),
              InkWell(
                onTap: () => UrlUtils.openEmail('contact@mysavvybee.com'),
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text:
                        'To change your account details, please contact support at ',
                    style: TextStyle(
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                    children: [
                      TextSpan(
                        text: 'contact@mysavvybee.com',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const SizedBox(),
        error: (error, stackTrace) => const SizedBox(),
      ),
    );
  }

  Widget _buildRowItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.grey,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
          ),
        ],
      ),
    );
  }
}
