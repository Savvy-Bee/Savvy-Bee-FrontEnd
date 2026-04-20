import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/custom_input_field.dart';
import 'internal_enter_amount_screen.dart';

class InternalTransferScreen extends ConsumerStatefulWidget {
  static const String path = '/internal-transfer';

  final String? initialUsername;

  const InternalTransferScreen({super.key, this.initialUsername});

  @override
  ConsumerState<InternalTransferScreen> createState() =>
      _InternalTransferScreenState();
}

class _InternalTransferScreenState
    extends ConsumerState<InternalTransferScreen> {
  late final _usernameController = TextEditingController(
    text: widget.initialUsername,
  );

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  bool get _canContinue => _usernameController.text.trim().isNotEmpty;

  void _onContinue() {
    if (!_canContinue) return;
    context.pushNamed(
      InternalEnterAmountScreen.path,
      extra: _usernameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send to Savvy Bee User'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _canContinue ? _onContinue : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey.shade200,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                color: _canContinue ? Colors.white : Colors.grey.shade400,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomTextFormField(
            label: 'Username',
            hint: 'e.g. johndoe',
            isRounded: false,
            labelBold: true,
            focusBorderColor: Colors.black,
            controller: _usernameController,
            onChanged: (_) => setState(() {}),
            prefixIcon: const Icon(
              Icons.alternate_email,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the username of the Savvy Bee user you want to send money to.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
