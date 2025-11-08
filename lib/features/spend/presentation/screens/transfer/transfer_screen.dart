import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_dropdown_button.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/send_money_screen.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_input_field.dart';
import '../../widgets/copy_text_icon_button.dart';
import '../../widgets/mini_button.dart';

class TransferScreen extends ConsumerStatefulWidget {
  static String path = '/transfer';

  const TransferScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _accNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send to any bank'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: MiniButton(
              text: 'Next',
              onTap: () => _AccountConfirmationBottomSheet.show(
                context,
                accountName: 'Aegon targaryen',
                bankName: 'First Bank of Nigeria',
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Recent transfers',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Gap(8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 24,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                8,
                (index) => _buildRecentItem('Aegon Targaryen'),
              ),
            ),
          ),
          const Gap(16),
          CustomTextFormField(
            label: 'Account Number',
            isRounded: true,
            controller: _accNumberController,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CopyTextIconButton(label: 'Paste', onPressed: () {}),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const Gap(4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: AppColors.primary, size: 16),
              const Gap(4),
              Text(
                'Aegon targaryen',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Gap(16),
          CustomDropdownButton(
            items: [],
            hint: 'Bank name',
            label: 'Bank',
            leadingIcon: AppIcon(AppIcons.bankIcon),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String name) {
    var textStyle = TextStyle(
      height: 1.1,
      fontSize: 10,
      fontFamily: Constants.neulisNeueFontFamily,
    );
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.ac_unit_rounded, color: AppColors.success),
          ),
          const Gap(8),
          Text(
            name.split(' ').join('\n'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}

class _AccountConfirmationBottomSheet extends StatelessWidget {
  final String accountName;
  final String bankName;

  const _AccountConfirmationBottomSheet({
    required this.accountName,
    required this.bankName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(8),
          Container(
            width: 40,
            padding: EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Gap(24),
          SvgPicture.asset(Assets.bankSvg),
          const Gap(24),
          Text(
            accountName,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Gap(16),
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: 'You are sending to ',
              children: [
                TextSpan(
                  text: '$accountName ($bankName).',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: 'Is this correct?'),
              ],
              style: TextStyle(
                fontSize: 12,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
          ),
          const Gap(24),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: CustomOutlinedButton(text: 'Cancel', onPressed: () {}),
              ),
              Expanded(
                child: CustomElevatedButton(
                  text: 'Confirm',
                  buttonColor: CustomButtonColor.black,
                  onPressed: () => context.pushNamed(
                    SendMoneyScreen.path,
                    extra: 'Aegon Targaryen',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String accountName,
    required String bankName,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _AccountConfirmationBottomSheet(
        accountName: accountName,
        bankName: bankName,
      ),
    );
  }
}
