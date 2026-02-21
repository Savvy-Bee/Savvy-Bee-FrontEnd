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
  // Retry configuration
  static const int maxRetries = 4;
  int currentRetryAttempt = 0;
  String statusMessage = 'Syncing your information. Please wait...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        ConnectConfiguration configuration = await _connectionConfig();

        if (mounted) {
          MonoConnect.launch(context, config: configuration, showLogs: true);
        }
      } catch (e) {
        log('❌ Error in initState: $e');
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

    // Decrypt BVN with error handling
    String? decryptedBvn;
    try {
      if (customer.identity != null && customer.identity!.isNotEmpty) {
        decryptedBvn = EncryptionService.decryptData(customer.identity!);
        log('✅ BVN decrypted successfully');
      }
    } catch (e) {
      log('❌ Failed to decrypt BVN: $e');
      throw Exception(
        'Failed to decrypt your identity information. Please try again.',
      );
    }

    final isExistingCustomer =
        customer.monoCustomerId != null && customer.monoCustomerId!.isNotEmpty;

    log('🔧 Configuring Mono Connect:');
    log('   - Customer: ${customer.name}');
    log('   - Email: ${customer.email}');
    log('   - Institution: ${widget.institution.institution}');

    return ConnectConfiguration(
      publicKey: Constants.monoPublic,
      onSuccess: (code) async {
        log('✅ Mono Connect Success with code: $code');
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
        log('📱 Mono Event: $event');
      },
      onClose: () {
        log('❌ Mono Connect closed by user');
        if (mounted) {
          context.pop();
        }
      },
    );
  }

  /// Handle link account with automatic retry logic
  Future<void> _handleLinkAccountWithRetry(String code) async {
    currentRetryAttempt = 0;

    while (currentRetryAttempt < maxRetries) {
      currentRetryAttempt++;

      log('🔄 Link attempt $currentRetryAttempt/$maxRetries');

      // Update UI with retry status
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
          log('✅ Account linked successfully on attempt $currentRetryAttempt');
          context.pop();

          BankConnectionStatusBottomSheet.show(
            context,
            bankName: widget.institution.displayName,
          );
          return; // ✅ Success - exit retry loop
        } else {
          log(
            '❌ Failed on attempt $currentRetryAttempt - success flag: $success',
          );

          // If this was the last attempt, show error
          if (currentRetryAttempt >= maxRetries) {
            _showFinalError(
              'We couldn\'t link your ${widget.institution.displayName} account after $maxRetries attempts. Please try again later.',
            );
            return;
          }

          // Wait before retrying (exponential backoff)
          await _waitBeforeRetry(currentRetryAttempt);
        }
      } catch (e) {
        log('❌ Error on attempt $currentRetryAttempt: $e');

        // If this was the last attempt, show error
        if (currentRetryAttempt >= maxRetries) {
          if (!mounted) return;

          String errorMessage = _extractErrorMessage(e.toString());
          _showFinalError('$errorMessage (Failed after $maxRetries attempts)');
          return;
        }

        // Wait before retrying (exponential backoff)
        await _waitBeforeRetry(currentRetryAttempt);
      }
    }
  }

  /// Wait before next retry with exponential backoff
  /// Attempt 1 -> wait 1 second
  /// Attempt 2 -> wait 2 seconds
  /// Attempt 3 -> wait 3 seconds
  /// Attempt 4 -> wait 4 seconds
  Future<void> _waitBeforeRetry(int attemptNumber) async {
    final waitSeconds = attemptNumber; // Simple linear backoff
    log('⏳ Waiting $waitSeconds seconds before retry...');

    if (mounted) {
      setState(() {
        statusMessage = 'Retrying in $waitSeconds seconds...';
      });
    }

    await Future.delayed(Duration(seconds: waitSeconds));
  }

  /// Show final error after all retries exhausted
  void _showFinalError(String message) {
    if (!mounted) return;

    log('🛑 All retry attempts exhausted. Showing final error.');

    _showErrorMessage(message);

    // Close bottom sheet after user sees the error
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.pop();
      }
    });
  }

  /// Extract a user-friendly error message from exception
  String _extractErrorMessage(String error) {
    if (error.contains('400')) {
      return 'Issue on our end. Please try again in a moment.';
    }
    if (error.contains('401') || error.contains('unauthorized')) {
      return 'Authentication failed. Please check your credentials.';
    }
    if (error.contains('404')) {
      return 'Service not found. Please contact support.';
    }
    if (error.contains('500') || error.contains('internal')) {
      return 'Server error. We\'re working on it!';
    }
    if (error.contains('network') || error.contains('connection')) {
      return 'Network error. Check your connection and try again.';
    }
    if (error.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    return 'Unable to link your account. Please try again later.';
  }

  /// Show error message to user via SnackBar
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
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'GeneralSans',
                    letterSpacing: 32 * 0.02,),
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
          // ✅ Dynamic status message showing retry progress
          Text(
            statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontFamily: 'GeneralSans',
                    letterSpacing: 14 * 0.02,),
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

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mono_connect/mono_connect.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/utils/string_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/bank_connection_status_bottom_sheet.dart';
// import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';
// import 'package:savvy_bee_mobile/features/profile/data/services/encryption_service.dart';

// import '../../../../../spend/domain/models/mono_institution.dart';

// class ProcessingConnectionBottomSheet extends ConsumerStatefulWidget {
//   final MonoInputData inputData;
//   final MonoInstitution institution;

//   const ProcessingConnectionBottomSheet({
//     super.key,
//     required this.inputData,
//     required this.institution,
//   });

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _ProcessingConnectionBottomSheetState();

//   static void show(
//     BuildContext context, {
//     required MonoInputData inputData,
//     required MonoInstitution institution,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       isDismissible: false,
//       enableDrag: false,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => ProcessingConnectionBottomSheet(
//         inputData: inputData,
//         institution: institution,
//       ),
//     );
//   }
// }

// class _ProcessingConnectionBottomSheetState
//     extends ConsumerState<ProcessingConnectionBottomSheet> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       ConnectConfiguration configuration = await _connectionConfig();

//       if (mounted) {
//         MonoConnect.launch(context, config: configuration, showLogs: true);
//       }
//     });
//   }

//   Future<ConnectConfiguration> _connectionConfig() async {
//     final customer = widget.inputData;

//     // Decrypt BVN
//     final decryptedBvn = EncryptionService.decryptData(customer.identity);

//     final isExistingCustomer =
//         customer.monoCustomerId != null && customer.monoCustomerId!.isNotEmpty;

//     return ConnectConfiguration(
//       publicKey: Constants.monoPublic,
//       onSuccess: (code) async {
//         log('Success with code: $code');

//         await _handleLinkAccount(code);
//       },
//       customer: MonoCustomer(
//         newCustomer: isExistingCustomer
//             ? null
//             : MonoNewCustomer(
//                 name: customer.name,
//                 email: customer.email,
//                 identity: MonoCustomerIdentity(
//                   type: 'bvn',
//                   number: decryptedBvn ?? '2323233239',
//                 ),
//               ),

//         // If the user has a mono id, they're an existing customer
//         existingCustomer: isExistingCustomer
//             ? MonoExistingCustomer(id: customer.monoCustomerId!)
//             : null,
//       ),
//       selectedInstitution: ConnectInstitution(
//         id: widget.institution.id,
//         authMethod: ConnectAuthMethod.mobileBanking,
//       ),
//       onEvent: (event) {
//         log('***************** Event: $event *****************');
//       },
//       onClose: () {
//         context.pop();
//       },
//     );
//   }

//   Future<void> _handleLinkAccount(String code) async {
//     try {
//       final success = await ref
//           .read(linkedAccountsProvider.notifier)
//           .linkAccount(code);

//       if (success && mounted) {
//         context.pop();

//         BankConnectionStatusBottomSheet.show(
//           context,
//           bankName: widget.institution.displayName,
//         );
//       }
//     } catch (e) {
//       log('Error linking account: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               IconButton(
//                 onPressed: () => context.pop(),
//                 style: Constants.collapsedButtonStyle,
//                 icon: Icon(Icons.close),
//               ),
//             ],
//           ),
//           const Gap(32),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CustomCard(
//                 padding: const EdgeInsets.all(20),
//                 borderRadius: 8,
//                 child: Image.asset(Logos.logo, scale: 4),
//               ),
//               SizedBox(width: 37, child: const Divider()),
//               CustomCard(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 24,
//                   horizontal: 16,
//                 ),
//                 borderRadius: 8,
//                 child: Text(
//                   widget.institution.institution.truncate(20),
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//           const Gap(32),
//           Text(
//             'Connecting to ${widget.institution.institution}',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//           ),
//           const Gap(32),
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(width: 55, child: LinearProgressIndicator()),
//               AppIcon(AppIcons.progressIcon, color: AppColors.primary),
//             ],
//           ),
//           const Gap(32),
//           Text('Syncing your information. Please wait...'),
//           const Gap(32),
//         ],
//       ),
//     );
//   }
// }
