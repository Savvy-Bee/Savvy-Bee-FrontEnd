import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_dropdown_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/outlined_card.dart';
import '../../../../spend/presentation/widgets/copy_text_icon_button.dart';

enum DebtRepaymentMethod { bankTransfer, card }

class DebtRepaymentDetailsScreen extends ConsumerStatefulWidget {
  static String path = '/debt-repayment-details';

  const DebtRepaymentDetailsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DebtRepaymentDetailsScreenState();
}

class _DebtRepaymentDetailsScreenState
    extends ConsumerState<DebtRepaymentDetailsScreen> {
  final _accNumberController = TextEditingController();

  DebtRepaymentMethod _repaymentMethod = DebtRepaymentMethod.bankTransfer;

  bool _hasAgreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debt repayment details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'How would you like to pay this debt?',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(8),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: _buildPaymentOptionButton(
                          'Bank transfer',
                          isSelected:
                              _repaymentMethod ==
                              DebtRepaymentMethod.bankTransfer,
                          onTap: () {
                            setState(() {
                              _repaymentMethod =
                                  DebtRepaymentMethod.bankTransfer;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildPaymentOptionButton(
                          'Card',
                          isSelected:
                              _repaymentMethod == DebtRepaymentMethod.card,
                          onTap: () {
                            setState(() {
                              _repaymentMethod = DebtRepaymentMethod.card;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  CustomTextFormField(
                    label: 'Account Number',
                    isRounded: true,
                    controller: _accNumberController,
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: CopyTextIconButton(
                        label: 'Paste',
                        onPressed: () {},
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  const Gap(4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const Gap(4),
                      Text(
                        'Aegon targaryen',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: Constants.neulisNeueFontFamily,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  CustomDropdownButton(
                    items: [],
                    hint: 'Bank name',
                    label: 'Bank',
                    leadingIcon: AppIcon(AppIcons.bankIcon),
                  ),
                  const Gap(16),
                  InsightCard(
                    text:
                        'We will send you a reminder when each repayment is due',
                    insightType: InsightType.nextBestAction,
                  ),
                  const Gap(16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _hasAgreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _hasAgreedToTerms = !_hasAgreedToTerms;
                          });
                        },
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text.rich(
                          style: TextStyle(fontSize: 12),
                          TextSpan(
                            text:
                                'I hereby agree to Nahl automatically repaying this debt from my Savvy Wallet to ',
                            children: [
                              TextSpan(
                                text: 'Aegon Targaryen (First Bank) ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'on the '),
                              TextSpan(
                                text: 'first day of every month ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'until the debt has been fully repaid',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CustomElevatedButton(
              text: 'Add repayment details',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionButton(
    String text, {
    isSelected = false,
    VoidCallback? onTap,
  }) {
    return OutlinedCard(
      borderWidth: isSelected ? 2 : null,
      borderRadius: 8,
      onTap: onTap,
      borderColor: isSelected ? AppColors.primary : null,
      child: Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
