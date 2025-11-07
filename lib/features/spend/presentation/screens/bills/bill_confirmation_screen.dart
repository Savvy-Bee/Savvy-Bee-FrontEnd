import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_completion_screen.dart';

class BillConfirmationScreen extends ConsumerStatefulWidget {
  static String path = '/confirmation';

  const BillConfirmationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BillConfirmationScreenState();
}

class _BillConfirmationScreenState
    extends ConsumerState<BillConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              const Gap(4),
              Text(
                '08012345678',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              const Gap(16),
              Text(
                'Amount',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              const Gap(4),
              Text(
                NumberFormatter.formatCurrency(3000, decimalDigits: 0),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ],
          ),
          const Gap(16),
          OutlinedCard(
            onTap: () => context.pushNamed(BillCompletionScreen.path),
            borderRadius: 50,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'From:',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                    Text(
                      '1234567890',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction Fee:',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                    Text(
                      NumberFormatter.formatCurrency(0),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Description:',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              Text(
                'Airtime',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Network:',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              Text(
                'GLO-NG',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
