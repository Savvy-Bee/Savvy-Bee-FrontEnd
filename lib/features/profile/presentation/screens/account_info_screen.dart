import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/avatars.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/url_utils.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';

class AccountInfoScreen extends ConsumerStatefulWidget {
  static String path = '/account-info';

  const AccountInfoScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AccountInfoScreenState();
}

class _AccountInfoScreenState extends ConsumerState<AccountInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Info')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Image.asset(Avatars.luna5, width: 100, height: 100),
                  ),
                  const Gap(16),
                  GameCard(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRowItem('Name', 'Danaerys Targaryen'),
                        const Divider(height: 0),
                        _buildRowItem('Email', 'danytargaryen@gmail.com'),
                        const Divider(height: 0),
                        _buildRowItem('Date of birth', '26th December, 2000'),
                        const Divider(height: 0),
                        _buildRowItem('Country of residence', 'Nigeria'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              spacing: 16,
              children: [
                CustomElevatedButton(
                  text: 'Edit Account Info',
                  onPressed: () {},
                ),
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
          ],
        ),
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
