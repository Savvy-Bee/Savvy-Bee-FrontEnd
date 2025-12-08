import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mono_connect/mono_connect.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/encryption_service.dart';
import 'package:savvy_bee_mobile/core/utils/string_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/bank_connection_status_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';

import '../../../../../spend/domain/models/institution.dart';

class ProcessingConnectionBottomSheet extends ConsumerStatefulWidget {
  final MonoInputData inputData;
  final Institution institution;

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
    required Institution institution,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
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
  Future<ConnectConfiguration> _connectionConfig() async {
    final customer = widget.inputData;

    // Decrypt BVN
    final decryptedBvn = await EncryptionService.decryptText(customer.identity);

    return ConnectConfiguration(
      publicKey: dotenv.env[Constants.monoPublic]!,
      onSuccess: (code) {
        log('Success with code: $code');
        context.pop();
        BankConnectionStatusBottomSheet.show(
          context,
          bankName: widget.institution.displayName,
        );
      },
      customer: MonoCustomer(
        // If the user doesn't have a mono id, they're a new customer
        newCustomer:
            customer.monoCustomerId == null || customer.monoCustomerId!.isEmpty
            ? null
            : MonoNewCustomer(
                name: customer.name,
                email: customer.email,
                identity: MonoCustomerIdentity(
                  type: 'bvn',
                  number: decryptedBvn ?? '2323233239',
                ),
              ),

        // If the user has a mono id, they're an existing customer
        existingCustomer:
            customer.monoCustomerId == null || customer.monoCustomerId!.isEmpty
            ? null
            : MonoExistingCustomer(id: customer.monoCustomerId!),
      ),
      selectedInstitution: ConnectInstitution(
        id: widget.institution.id,
        authMethod: ConnectAuthMethod.mobileBanking,
      ),
      onEvent: (event) {
        log(event.toString());
      },
      onClose: () {
        log('Widget closed.');
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ConnectConfiguration configuration = await _connectionConfig();

      if (mounted) {
        MonoConnect.launch(context, config: configuration, showLogs: true);
      }
    });
  }

  void _handleLinkAccount(String code) async {
    try {
      final response = await ref
          .read(linkedAccountsProvider.notifier)
          .linkAccount(code);
    } catch (e) {}
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
                onPressed: () => context.pop(),
                style: Constants.collapsedButtonStyle,
                icon: Icon(Icons.close),
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
              SizedBox(width: 37, child: const Divider()),
              CustomCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                borderRadius: 8,
                child: Text(
                  widget.institution.institution.truncate(20),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Gap(32),
          Text(
            'Connecting to ${widget.institution.institution}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 55, child: LinearProgressIndicator()),
              AppIcon(AppIcons.progressIcon, color: AppColors.primary),
            ],
          ),
          const Gap(32),
          Text(
            'Syncing your information. Please wait...',
            style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
          ),
          const Gap(32),
        ],
      ),
    );
  }
}
