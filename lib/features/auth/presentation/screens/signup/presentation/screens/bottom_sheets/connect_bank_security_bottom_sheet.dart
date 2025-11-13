import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/presentation/screens/bottom_sheets/select_bank_bottom_sheet.dart';

class ConnectBankSecurityBottomSheet extends StatelessWidget {
  const ConnectBankSecurityBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ConnectBankSecurityBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    style: Constants.collapsedButtonStyle,
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const Gap(24),
              Text(
                'Savvy Bee uses\nMono to connect\nyour bank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                  height: 1.1,
                ),
              ),

              const Gap(24),
              _buildInfoCard(),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
                textAlign: TextAlign.center,
                TextSpan(
                  text: "By continuing, you agree to Mono's ",
                  children: [
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              CustomElevatedButton(
                text: 'Continue',
                showArrow: true,
                buttonColor: CustomButtonColor.black,
                onPressed: () => SelectBankBottomSheet.show(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String subtitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(AppIcons.chartSquareIcon),
        const Gap(22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              Text(subtitle, style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return CustomCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoItem(
            'Connect effortlessly',
            'Mono lets you securely connect your financial accounts in seconds',
          ),
          const Gap(16),
          _buildInfoItem(
            'Your data belongs to you',
            "Mono doesn't give us your personal info and will only use it with your permission",
          ),
          const Gap(16),
          _buildInfoItem(
            'Protect your accounts',
            'Mono helps minimise fraud and risk by using account info, transaction history, and connection history.',
          ),
          const Gap(16),
          _buildInfoItem(
            'Safe and secure',
            "Savvy Bee can't move your money and we never store bank login details.",
          ),
        ],
      ),
    );
  }
}
