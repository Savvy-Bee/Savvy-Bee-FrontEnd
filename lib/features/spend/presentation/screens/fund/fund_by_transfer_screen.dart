import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/copy_text_icon_button.dart';

class FundByTransferScreen extends ConsumerWidget {
  static const String path = '/fund-by-transfer';

  const FundByTransferScreen({super.key});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fund by Transfer')),
      body: dashboardAsync.when(
        loading: () => const CustomLoadingWidget(),
        error: (_, __) => CustomErrorWidget.error(
          onRetry: () => ref.invalidate(spendDashboardDataProvider),
        ),
        data: (response) {
          final account = response.data?.accounts.ngnAccount;

          if (account == null) {
            return const CustomErrorWidget(
              subtitle: 'No wallet account found. Please create a wallet first.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Use the details below to send money to your Savvy Bee Wallet from any bank's app or through internet banking.",
              ),
              const Gap(24),
              _buildReadOnlyField(
                label: 'Bank',
                value: account.bankName,
              ),
              const Gap(8),
              _buildFieldWithCopy(
                context: context,
                label: 'Account Number',
                value: account.accountNumber,
                copyLabel: 'Account number',
              ),
              const Gap(8),
              _buildReadOnlyField(
                label: 'Account Name',
                value: account.accountName,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return CustomTextFormField(
      label: label,
      isRounded: true,
      controller: TextEditingController(text: value),
      readOnly: true,
    );
  }

  Widget _buildFieldWithCopy({
    required BuildContext context,
    required String label,
    required String value,
    required String copyLabel,
  }) {
    return CustomTextFormField(
      label: label,
      isRounded: true,
      controller: TextEditingController(text: value),
      readOnly: true,
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: CopyTextIconButton(
          label: 'Copy',
          onPressed: () => _copyToClipboard(context, value, copyLabel),
        ),
      ),
    );
  }
}
