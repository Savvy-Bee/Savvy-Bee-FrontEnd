import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/core/widgets/info_widget.dart';
import 'package:savvy_bee_mobile/features/action_completed_screen.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/bvn_verification_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/nin_verification_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spend_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/pin_bottom_sheet.dart';

class CreateWalletScreen extends ConsumerStatefulWidget {
  static const String path = '/wallet';

  const CreateWalletScreen({super.key});

  @override
  ConsumerState<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends ConsumerState<CreateWalletScreen> {
  bool _isCreating = false;

  Future<void> _onGetStarted(bool ninVerified, bool bvnVerified) async {
    if (!ninVerified) {
      context.pushNamed(NinVerificationScreen.path);
      return;
    }
    if (!bvnVerified) {
      context.pushNamed(BvnVerificationScreen.path);
      return;
    }

    // Both verified — prompt PIN and create the wallet
    final pin = await PinBottomSheet.show(
      context,
      title: 'Create Your Wallet',
      subtitle:
          'Enter your 4-digit transaction PIN to create your Savvy Wallet.',
      confirmLabel: 'Create Wallet',
    );

    if (pin == null || !mounted) return;

    setState(() => _isCreating = true);

    try {
      final response = await ref
          .read(walletRepositoryProvider)
          .createNairaAccount(pin: pin);

      if (!mounted) return;

      if (response.success) {
        // Refresh the spend dashboard so SpendScreen reflects the new wallet.
        // transactionListProvider is autoDispose and re-fetches on its own
        // when SpendScreen remounts — no need to invalidate it here.
        ref.invalidate(spendDashboardDataProvider);

        context.goNamed(
          ActionCompletedScreen.path,
          extra: ActionInfo(
            title: 'Wallet Created!',
            message: 'Your Savvy Wallet has been created successfully.',
            actionText: 'Go to Wallet',
            redirectPath: SpendScreen.path,
          ),
        );
      } else {
        CustomSnackbar.show(
          context,
          response.message.isNotEmpty
              ? response.message
              : 'Failed to create wallet. Please try again.',
          type: SnackbarType.error,
          position: SnackbarPosition.bottom,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      CustomSnackbar.show(
        context,
        msg,
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Wallet')),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24.0,
        ).copyWith(bottom: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InfoWidget(
              title: 'Verify your identity to create your wallet',
              subtitle:
                  'To keep your wallet secure and comply with regulations, we need to verify your identity using your NIN, BVN, and a quick live photo.',
              icon: SvgPicture.asset(Assets.verifySvg),
            ),
            homeDataAsync.when(
              loading: () => CustomElevatedButton(
                text: 'Get Started',
                onPressed: null,
                buttonColor: CustomButtonColor.black,
                showArrow: true,
                isLoading: true,
              ),
              error: (_, __) => CustomElevatedButton(
                text: 'Get Started',
                onPressed: _isCreating
                    ? null
                    : () => _onGetStarted(false, false),
                buttonColor: CustomButtonColor.black,
                showArrow: !_isCreating,
                isLoading: _isCreating,
              ),
              data: (homeData) {
                final ninVerified = homeData.data.kyc.nin;
                final bvnVerified = homeData.data.kyc.bvn;
                final bothVerified = ninVerified && bvnVerified;

                return CustomElevatedButton(
                  text: bothVerified ? 'Create Wallet' : 'Get Started',
                  onPressed: _isCreating
                      ? null
                      : () => _onGetStarted(ninVerified, bvnVerified),
                  buttonColor: CustomButtonColor.black,
                  showArrow: !_isCreating,
                  isLoading: _isCreating,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
