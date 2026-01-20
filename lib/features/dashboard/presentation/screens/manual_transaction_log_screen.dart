import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_dropdown_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';

class ManualTransactionLogScreen extends ConsumerStatefulWidget {
  static String path = '/manual-transaction-log';

  const ManualTransactionLogScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManualTransactionLogScreenState();
}

class _ManualTransactionLogScreenState
    extends ConsumerState<ManualTransactionLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            IntroText(
              title: 'Add a Transaction',
              subtitle: 'Enter the details for your custom transaction below.',
            ),
            const Gap(24),

            _buildTabBar(),
            const Gap(24),

            _buildSpendSection(_tabController.index == 0),
            // Flexible(
            //   child: TabBarView(
            //     controller: _tabController,
            //     children: [
            //       _buildSpendSection(_tabController.index == 0),
            //       _buildIncomeSection(),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomElevatedButton(
          text: 'Save',
          onPressed: () {},
          buttonColor: CustomButtonColor.black,
        ),
      ),
    );
  }

  // Widget _buildIncomeSection() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       CustomTextFormField(label: 'Name*'),
  //       const Gap(16),
  //       CustomTextFormField(
  //         label: 'Date*',
  //         readOnly: true,
  //         suffixIcon: Icon(Icons.calendar_month_outlined),
  //       ),
  //       const Gap(16),
  //       CustomTextFormField(
  //         label: 'Amount*',
  //         keyboardType: TextInputType.number,
  //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //       ),
  //       const Gap(16),
  //     ],
  //   );
  // }

  Widget _buildSpendSection(bool isSpendSection) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextFormField(label: 'Name*'),
        const Gap(16),
        CustomTextFormField(
          label: 'Date*',
          readOnly: true,
          suffixIcon: Icon(Icons.calendar_month_outlined),
        ),
        const Gap(16),
        CustomTextFormField(
          label: 'Amount*',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        if (isSpendSection) const Gap(16),
        if (isSpendSection)
          CustomDropdownButton(
            label: 'Category',
            hint: 'Select a category',
            items: [],
          ),
        if (isSpendSection) const Gap(16),
        if (isSpendSection)
          CustomDropdownButton(
            label: 'Account*',
            hint: 'Select account',
            items: [],
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    var borderRadius = BorderRadius.circular(40);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: borderRadius,
        boxShadow: [BoxShadow(blurRadius: 2, color: AppColors.greyLight)],
      ),
      child: TabBar(
        controller: _tabController,
        onFocusChange: (_, _) {
          setState(() {});
        },
        onTap: (_) {
          setState(() {});
        },
        tabs: [
          Tab(text: 'Spend'),
          Tab(text: 'Income'),
        ],
        dividerHeight: 0,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: borderRadius,
        ),
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        unselectedLabelColor: AppColors.black,
      ),
    );
  }
}
