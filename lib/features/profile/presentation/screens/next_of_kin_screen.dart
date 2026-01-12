import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_dropdown_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/action_completed_screen.dart';

import '../../../../core/widgets/custom_button.dart';

class NextOfKinScreen extends ConsumerStatefulWidget {
  static const String path = '/next-of-kin';

  const NextOfKinScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NextOfKinScreenState();
}

class _NextOfKinScreenState extends ConsumerState<NextOfKinScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Next of Kin')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Next of Kin (NOK)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                const Gap(8),
                Text(
                  '''Your next of kin is the closest living relative to you. The next-of-kin relationship is important in determining inheritance rights if a person dies without a will and has no spouse and/or children.
          
We will contact this person if we are unable to make contact with you after a long period of time.''',
                  style: TextStyle(fontSize: 12),
                ),
                const Gap(16),
                CustomTextFormField(
                  label: 'Next of kin',
                  hint: 'Jane Doe',
                  controller: _nameController,
                ),
                const Gap(16),
                CustomDropdownButton(
                  label: 'What is the relationship?',
                  hint: 'Cousin',
                  items: [
                    'Father',
                    'Mother',
                    'Brother',
                    'Sister',
                    'Uncle',
                    'Aunt',
                    'Cousin',
                    'Nephew',
                    'Niece',
                  ],
                ),
                const Gap(16),
                CustomTextFormField(
                  label: 'Email address of next of kin',
                  hint: 'janedoe@email.com',
                  controller: _emailController,
                ),
                const Gap(16),
                CustomTextFormField(
                  label: 'Phone number of next of kin',
                  hint: '081234567890',
                  controller: _phoneNumberController,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomElevatedButton(
              text: 'Update Next of Kin',
              onPressed: () => context.pushNamed(
                ActionCompletedScreen.path,
                extra: ActionInfo(
                  title: 'Updated!',
                  message: 'Your next of kin information has been updated.',
                  actionText: 'Okay',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
