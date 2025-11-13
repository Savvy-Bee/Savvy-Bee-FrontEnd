import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/account_statement_screen.dart';

import '../../../../../core/utils/assets/assets.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  static String path = '/transaction-history';

  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaction History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    isRounded: true,
                    hint: 'Search',
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                const Gap(16),
                InkWell(
                  onTap: () => context.pushNamed(AccountStatementScreen.path),
                  child: Icon(
                    Icons.file_copy_outlined,
                    color: AppColors.greyDark,
                  ),
                ),
              ],
            ),
            const Gap(16),
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (context, index) => Gap(16),
                itemBuilder: (context, index) => TransactionHistoryCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionHistoryCard extends StatelessWidget {
  const TransactionHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nov 01, 2025',
          style: TextStyle(
            fontSize: 12,
            fontFamily: Constants.neulisNeueFontFamily,
          ),
        ),
        const Gap(8),
        CustomCard(
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => _buildTransactionItem(
                title: 'E Transfer Sent to Tem ...',
                time: '4:07PM',
                amount: NumberFormatter.formatCurrency(23445, decimalDigits: 0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String time,
    required String amount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(Assets.coinStackSvg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: Constants.neulisNeueFontFamily,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: Constants.neulisNeueFontFamily,
          ),
        ),
      ],
    );
  }
}
