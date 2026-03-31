import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mono_connect/mono_connect.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/string_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/bank_connection_status_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';
import 'package:savvy_bee_mobile/features/profile/data/services/encryption_service.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';

import '../../../../../spend/domain/models/mono_institution.dart';

class ProcessingConnectionBottomSheet extends ConsumerStatefulWidget {
  final MonoInputData inputData;
  final MonoInstitution institution;

  const ProcessingConnectionBottomSheet({
    super.key,
    required this.inputData,
    required this.institution,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProcessingConnectionBottomSheetState();

  static void show(
    BuildContext context, {
    required MonoInputData inputData,
    required MonoInstitution institution,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ProcessingConnectionBottomSheet(
        inputData: inputData,
        institution: institution,
      ),
    );
  }
}

class _ProcessingConnectionBottomSheetState
    extends ConsumerState<ProcessingConnectionBottomSheet> {
  static const int maxRetries = 4;
  int currentRetryAttempt = 0;
  String statusMessage = 'Syncing your information. Please wait...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final configuration = await _connectionConfig();

        if (mounted) {
          MonoConnect.launch(context, config: configuration, showLogs: true);
        }
      } catch (e) {
        log('Error in initState: $e');
        if (mounted) {
          _showErrorMessage('Configuration error: ${e.toString()}');
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            context.pop();
          }
        }
      }
    });
  }

  Future<ConnectConfiguration> _connectionConfig() async {
    final customer = widget.inputData;

    String? decryptedBvn;
    try {
      if (customer.identity != null && customer.identity!.isNotEmpty) {
        decryptedBvn = EncryptionService.decryptData(customer.identity!);
      }
    } catch (e) {
      throw Exception(
        'Failed to decrypt your identity information. Please try again.',
      );
    }

    final isExistingCustomer =
        customer.monoCustomerId != null && customer.monoCustomerId!.isNotEmpty;

    return ConnectConfiguration(
      publicKey: Constants.monoPublic,
      onSuccess: (code) async {
        await _handleLinkAccountWithRetry(code);
      },
      customer: MonoCustomer(
        newCustomer: isExistingCustomer
            ? null
            : MonoNewCustomer(
                name: customer.name,
                email: customer.email,
                identity: decryptedBvn != null
                    ? MonoCustomerIdentity(type: 'bvn', number: decryptedBvn)
                    : null,
              ),
        existingCustomer: isExistingCustomer
            ? MonoExistingCustomer(id: customer.monoCustomerId!)
            : null,
      ),
      selectedInstitution: ConnectInstitution(
        id: widget.institution.id,
        authMethod: ConnectAuthMethod.mobileBanking,
      ),
      onEvent: (event) {
        log('Mono Event: $event');
      },
      onClose: () {
        if (mounted) {
          context.pop();
        }
      },
    );
  }

  Future<void> _handleLinkAccountWithRetry(String code) async {
    currentRetryAttempt = 0;

    while (currentRetryAttempt < maxRetries) {
      currentRetryAttempt++;

      if (mounted && currentRetryAttempt > 1) {
        setState(() {
          statusMessage =
              'Retrying... (Attempt $currentRetryAttempt/$maxRetries)';
        });
      }

      try {
        final success = await ref
            .read(linkedAccountsProvider.notifier)
            .linkAccount(code);

        if (!mounted) return;

        if (success) {
          context.pop();
          BankConnectionStatusBottomSheet.show(
            context,
            bankName: widget.institution.displayName,
          );
          return;
        }

        if (currentRetryAttempt >= maxRetries) {
          _showFinalError(
            'We couldn\'t link your ${widget.institution.displayName} account after $maxRetries attempts. Please try again later.',
          );
          return;
        }

        await _waitBeforeRetry(currentRetryAttempt);
      } catch (e) {
        if (_isVerificationRequiredError(e.toString())) {
          if (!mounted) return;
          await _showVerificationRequiredDialog();
          return;
        }

        if (currentRetryAttempt >= maxRetries) {
          if (!mounted) return;

          final errorMessage = _extractErrorMessage(e.toString());
          _showFinalError('$errorMessage (Failed after $maxRetries attempts)');
          return;
        }

        await _waitBeforeRetry(currentRetryAttempt);
      }
    }
  }

  bool _isVerificationRequiredError(String error) {
    final normalized = error.toLowerCase();
    return normalized.contains('bvn not verified') ||
        normalized.contains('bvn not verified yet') ||
        normalized.contains('nin not verified') ||
        (normalized.contains('verify') && normalized.contains('bvn')) ||
        (normalized.contains('verify') && normalized.contains('nin'));
  }

  Future<void> _showVerificationRequiredDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Verification Required',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Please verify your NIN and BVN in your profile before linking a bank account.',
          style: TextStyle(fontFamily: 'GeneralSans'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (!mounted) return;
              context.pop();
              context.goNamed(ProfileScreen.path);
            },
            child: const Text(
              'Go to profile',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _waitBeforeRetry(int attemptNumber) async {
    final waitSeconds = attemptNumber;

    if (mounted) {
      setState(() {
        statusMessage = 'Retrying in $waitSeconds seconds...';
      });
    }

    await Future.delayed(Duration(seconds: waitSeconds));
  }

  void _showFinalError(String message) {
    if (!mounted) return;

    _showErrorMessage(message);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.pop();
      }
    });
  }

  String _extractErrorMessage(String error) {
    final normalized = error.toLowerCase();

    if (normalized.contains('400')) {
      return 'Issue on our end. Please try again in a moment.';
    }
    if (normalized.contains('401') || normalized.contains('unauthorized')) {
      return 'Authentication failed. Please check your credentials.';
    }
    if (normalized.contains('404')) {
      return 'Service not found. Please contact support.';
    }
    if (normalized.contains('500') || normalized.contains('internal')) {
      return 'Server error. We\'re working on it!';
    }
    if (normalized.contains('network') || normalized.contains('connection')) {
      return 'Network error. Check your connection and try again.';
    }
    if (normalized.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    return 'Unable to link your account. Please try again later.';
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'GeneralSans',
                  letterSpacing: 14 * 0.02,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  if (mounted) {
                    context.pop();
                  }
                },
                style: Constants.collapsedButtonStyle,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Gap(32),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 8,
                child: Image.asset(Logos.logo, scale: 4),
              ),
              const SizedBox(width: 37, child: Divider()),
              CustomCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                borderRadius: 8,
                child: Text(
                  widget.institution.institution.truncate(20),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 16 * 0.02,
                  ),
                ),
              ),
            ],
          ),
          const Gap(32),
          Text(
            'Connecting to ${widget.institution.institution}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'GeneralSans',
              letterSpacing: 32 * 0.02,
            ),
          ),
          const Gap(32),
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(width: 55, child: LinearProgressIndicator()),
              AppIcon(AppIcons.progressIcon, color: AppColors.primary),
            ],
          ),
          const Gap(32),
          Text(
            statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'GeneralSans',
              letterSpacing: 14 * 0.02,
            ),
          ),
          if (currentRetryAttempt > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Attempt $currentRetryAttempt/$maxRetries',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'GeneralSans',
                  letterSpacing: 12 * 0.02,
                ),
              ),
            ),
          const Gap(32),
        ],
      ),
    );
  }
}
