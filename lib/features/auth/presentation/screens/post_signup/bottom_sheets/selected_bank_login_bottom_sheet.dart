import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/encryption_service.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/assets/app_icons.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_card.dart';
import '../../../../../spend/domain/models/institution.dart';
import 'processing_connection_bottom_sheet.dart';

import '../../../../../../core/utils/constants.dart';
import 'select_bank_bottom_sheet.dart';

class SelectedBankLoginBottomSheet extends ConsumerStatefulWidget {
  final Institution institution;

  const SelectedBankLoginBottomSheet({super.key, required this.institution});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectedBankLoginBottomSheetState();

  static void show(BuildContext context, {required Institution institution}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          SelectedBankLoginBottomSheet(institution: institution),
    );
  }
}

class _SelectedBankLoginBottomSheetState
    extends ConsumerState<SelectedBankLoginBottomSheet> {
  bool isLoadingData = false;

  void _fetchUserData() async {
    ProcessingConnectionBottomSheet.show(
      context,
      institution: widget.institution,
      inputData: MonoInputData(
        name: 'John Doe',
        email: 'info@savvybee.com',
        identity:
            await EncryptionService.encryptText('12345678909') ??
            '122dfdvf8909',
      ),
    );
    // try {
    //   setState(() => isLoadingData = true);

    //   final data = await ref.read(monoInputDataProvider.notifier).build();

    //   setState(() => isLoadingData = false);

    //   if (mounted) {
    //     ProcessingConnectionBottomSheet.show(
    //       context,
    //       institution: widget.institution,
    //       inputData: data,
    //     );
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     CustomSnackbar.show(
    //       context,
    //       'Failed to fetch user data. Please try again',
    //       type: SnackbarType.error,
    //       position: SnackbarPosition.bottom,
    //     );
    //   }
    //   setState(() => isLoadingData = false);
    // } finally {
    //   setState(() => isLoadingData = false);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.heightOf(context) / 1.7,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      context.pop();
                      SelectBankBottomSheet.show(context);
                    },
                    style: Constants.collapsedButtonStyle,
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const Gap(32),
              CustomCard(
                borderRadius: 8,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Text(
                  widget.institution.institution,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Gap(32),
              Text(
                'Login at ${widget.institution.displayName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              const Gap(32),
              _buildInfo(
                '1',
                "You'll be sent to ${widget.institution} to securely log in.",
              ),
              const Gap(16),
              _buildInfo('2', "Then you'll return here to finish connecting"),
              const Gap(32),
              CustomElevatedButton(
                text: 'Go to log in',
                buttonColor: CustomButtonColor.black,
                icon: AppIcon(
                  AppIcons.externalLinkIcon,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: _fetchUserData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(String number, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(),
          ),
          child: Text(
            number,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Gap(16),
        Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
      ],
    );
  }
}
