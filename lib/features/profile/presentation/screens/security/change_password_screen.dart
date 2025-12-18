import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  static String path = '/change-password';

  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _showOldPassword = false;
  bool _showNewPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'Change Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Gap(16),
                  CustomTextFormField(
                    label: 'Enter your current password',
                    hint: '●●●●●●●●',
                    controller: _oldPasswordController,
                    obscureText: !_showOldPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showOldPassword = !_showOldPassword;
                        });
                      },
                      icon: Icon(
                        _showOldPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  const Gap(16),
                  CustomTextFormField(
                    label: 'Enter NEW password',
                    hint: '●●●●●●●●',
                    controller: _newPasswordController,
                    obscureText: !_showNewPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showNewPassword = !_showNewPassword;
                        });
                      },
                      icon: Icon(
                        _showNewPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  const Gap(16),
                  Text.rich(
                    TextSpan(
                      text: 'You will be ',
                      style: TextStyle(fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'logged out',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              ' of your account and will be required to login with ',
                        ),
                        TextSpan(
                          text: 'your new password.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CustomElevatedButton(text: 'Update & Logout', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
