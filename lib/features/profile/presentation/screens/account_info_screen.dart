import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/avatars.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/url_utils.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/providers/delete_account_provider.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/widgets/delete_account_otp_dialog.dart';

class AccountInfoScreen extends ConsumerStatefulWidget {
  static const String path = '/account-info';

  const AccountInfoScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AccountInfoScreenState();
}

class _AccountInfoScreenState extends ConsumerState<AccountInfoScreen> {
  bool _isDeletingAccount = false;

  Future<void> _handleDeleteAccount(String userEmail) async {
    // Step 1: Show confirmation dialog
    final shouldDelete = await showDeleteAccountDialog(
      context,
      userEmail: userEmail,
      onDeleteConfirmed: () async {
        // Request deletion (sends OTP)
        await ref
            .read(deleteAccountNotifierProvider.notifier)
            .requestDeletion(userEmail);
      },
    );

    if (shouldDelete != true || !mounted) return;

    // Check if OTP was sent successfully
    final deleteState = ref.read(deleteAccountNotifierProvider);

    if (deleteState.error != null) {
      _showErrorSnackbar(deleteState.error!);
      return;
    }

    // if (!deleteState.isOtpSent) {
    //   _showErrorSnackbar('Failed to send verification code. Please try again.');
    //   return;
    // }

    // Step 2: Show OTP verification dialog
    final verified = await showDeleteAccountOtpDialog(
      context,
      userEmail: userEmail,
      onVerifyOtp: (otp) async {
        await ref
            .read(deleteAccountNotifierProvider.notifier)
            .verifyAndDelete(userEmail, otp);
      },
    );

    if (verified != true || !mounted) return;

    // Check if deletion was successful
    final finalState = ref.read(deleteAccountNotifierProvider);

    if (finalState.error != null) {
      _showErrorSnackbar(finalState.error!);
      return;
    }

    if (finalState.isDeleted) {
      // Show success message
      _showSuccessSnackbar('Account deleted successfully');

      // Wait a bit then navigate to login/onboarding
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        context.pushNamed(OnboardingScreen.path);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const Gap(12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const Gap(12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final deleteState = ref.watch(deleteAccountNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My account',
          style: TextStyle(
            fontFamily: 'General Sans',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: homeDataAsync.when(
        data: (data) {
          final user = data.data;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          Avatars.luna5,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const Gap(16),
                      GameCard(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRowItem(
                              'Name',
                              '${user.firstName} ${user.lastName}',
                            ),
                            const Divider(height: 0),
                            _buildRowItem('Email', user.email),
                            const Divider(height: 0),
                            _buildRowItem('Date of birth', user.dob),
                            const Divider(height: 0),
                            _buildRowItem('Country of residence', user.country),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => CustomErrorWidget.error(
          subtitle: error.toString(),
          onRetry: () => ref.refresh(homeDataProvider),
        ),
        loading: () => const CustomLoadingWidget(),
      ),
      bottomNavigationBar: homeDataAsync.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              // Delete Account button with red outline
              CustomOutlinedButton(
                text: 'Delete Account',
                isDestructive: true,
                isLoading: deleteState.isLoading,
                onPressed: deleteState.isLoading
                    ? null
                    : () => _handleDeleteAccount(data.data.email),
              ),
              InkWell(
                onTap: () => UrlUtils.openEmail('contact@mysavvybee.com'),
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text:
                        'To change your account details, please contact support at ',
                    style: const TextStyle(),
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
        ),
        loading: () => const SizedBox(),
        error: (error, stackTrace) => const SizedBox(),
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
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
