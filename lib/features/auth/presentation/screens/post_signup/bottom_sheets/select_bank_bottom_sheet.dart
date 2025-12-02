import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/selected_bank_login_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';

import '../../../../../../core/widgets/custom_error_widget.dart';
import '../../../../../spend/domain/models/institution.dart';

class SelectBankBottomSheet extends ConsumerStatefulWidget {
  const SelectBankBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectBankBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SelectBankBottomSheet(),
    );
  }
}

class _SelectBankBottomSheetState extends ConsumerState<SelectBankBottomSheet> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(institutionsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitleWidget(
            title: 'Add account',
            actionWidget: IconButton(
              onPressed: () => context.pop(),
              style: Constants.collapsedButtonStyle,
              icon: Icon(Icons.close),
            ),
          ),
          const Gap(16),
          CustomTextFormField(
            prefix: Icon(Icons.search),
            isRounded: true,
            controller: _searchController,
            hint: 'Search 1,000+ institutions',
          ),
          const Gap(16),
          Text(
            'Popular banks',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(16),
          Expanded(
            child: banksAsync.when(
              skipLoadingOnRefresh: false,
              data: (institutions) {
                return ListView(
                  children: [
                    GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(
                        institutions.length,
                        (index) => _buildBankCard(institutions[index]),
                      ),
                    ),
                  ],
                );
              },
              error: (error, stackTrace) => CustomErrorWidget.error(
                onRetry: () {
                  ref.invalidate(institutionsProvider);
                },
              ),
              loading: () => Center(child: const CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(Institution institution) {
    return CustomCard(
      onTap: () =>
          SelectedBankLoginBottomSheet.show(context, institution: institution),
      borderRadius: 8,
      child: Center(
        child: Text(
          institution.institution,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
