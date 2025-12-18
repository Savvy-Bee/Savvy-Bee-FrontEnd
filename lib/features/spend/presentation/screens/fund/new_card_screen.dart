import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';

import '../../widgets/copy_text_icon_button.dart';

class NewCardScreen extends ConsumerStatefulWidget {
  static String path = '/new-card';

  const NewCardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewCardScreenState();
}

class _NewCardScreenState extends ConsumerState<NewCardScreen> {
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add new card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                children: [
                  CustomTextFormField(
                    label: 'Name on Card',
                    hint: 'Your Name',
                    controller: _cardNameController,
                    isRounded: true,
                  ),
                  const Gap(8.0),
                  CustomTextFormField(
                    label: 'Card Number',
                    hint: '1234 1234 1234 1234',
                    controller: _cardNumberController,
                    isRounded: true,
                  ),
                  const Gap(8.0),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          label: 'Expiry Date',
                          hint: 'MM/YY',
                          controller: _expiryController,
                          isRounded: true,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: CustomTextFormField(
                          label: 'Card Number',
                          hint: '123',
                          controller: _cvvController,
                          isRounded: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CustomElevatedButton(
              text: 'Next',
              onPressed: () => AccountStatementBottomSheet.show(context),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountStatementBottomSheet extends StatelessWidget {
  AccountStatementBottomSheet({super.key});

  final _bankNameController = TextEditingController(text: 'Savvy Bee Bank');
  final _accNumberController = TextEditingController(text: '123456789');
  final _accNameController = TextEditingController(
    text: 'Danaerys Stormborn Targaryen',
  );

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
          const Gap(8),
          Text(
            'Account details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(24),
          CustomTextFormField(
            label: 'Bank',
            controller: _bankNameController,
            isRounded: true,
          ),
          const Gap(8),
          CustomTextFormField(
            label: 'Account Number',
            controller: _accNumberController,
            isRounded: true,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CopyTextIconButton(label: 'Copy', onPressed: () {}),
            ),
          ),
          const Gap(8),
          CustomTextFormField(
            label: 'Account Name',
            controller: _accNameController,
            isRounded: true,
          ),
          const Gap(24),
          CustomElevatedButton(
            text: 'Get account statement',
            showArrow: true,
            buttonColor: CustomButtonColor.black,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AccountStatementBottomSheet(),
    );
  }
}
