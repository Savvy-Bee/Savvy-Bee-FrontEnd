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
  ConnectConfiguration _connectionConfig() {
    return ConnectConfiguration(
      publicKey: 'test_pk_...',
      onSuccess: (code) {
        log('Success with code: $code');
      },
      customer: MonoCustomer(
        newCustomer: MonoNewCustomer(
          name: widget.inputData.name,
          email: 'samuel@neem.com',
          identity: MonoCustomerIdentity(type: 'bvn', number: '2323233239'),
        ),
        // or
        // existingCustomer: MonoExistingCustomer(id: '6759f68cb587236111eac1d4'),
      ),
      selectedInstitution: const ConnectInstitution(
        id: '5f2d08be60b92e2888287702',
        authMethod: ConnectAuthMethod.mobileBanking,
      ),
      reference: 'testref',
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

    MonoConnect.launch(context, config: _connectionConfig(), showLogs: true);
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
          AppIcon(AppIcons.progressIcon, color: AppColors.primary),
          const Gap(32),
          Text(
            'Syncing your information.',
            style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
          ),
          const Gap(32),
        ],
      ),
    );
  }
}
