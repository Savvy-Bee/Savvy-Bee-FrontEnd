import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/mini_button.dart';

import '../../widgets/copy_text_icon_button.dart';

class FundByTransferScreen extends ConsumerStatefulWidget {
  static const String path = '/fund-by-transfer';

  const FundByTransferScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FundByTransferScreenState();
}

class _FundByTransferScreenState extends ConsumerState<FundByTransferScreen> {
  final _bankNameController = TextEditingController(text: 'Savvy Bee Bank');
  final _accNumberController = TextEditingController(text: '1234567890');
  final _accNameController = TextEditingController(
    text: 'Danaerys Stormborn Targaryen',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
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
          Text(
            "Use the details below to send money to your Savvy Bee Wallet from any bank's app or through internet banking",
          ),
          const Gap(24),
          CustomTextFormField(
            label: 'Bank',
            isRounded: true,
            controller: _bankNameController,
          ),
          const Gap(8),
          CustomTextFormField(
            label: 'Account Number',
            isRounded: true,
            controller: _accNumberController,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CopyTextIconButton(label: 'Copy', onPressed: () {}),
            ),
          ),
          const Gap(8),
          CustomTextFormField(
            label: 'Account Name',
            isRounded: true,
            controller: _accNameController,
          ),
        ],
      ),
    );
  }
}
