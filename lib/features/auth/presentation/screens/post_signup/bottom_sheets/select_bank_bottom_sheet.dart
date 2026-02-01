import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/selected_bank_login_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';

import '../../../../../../core/widgets/custom_error_widget.dart';
import '../../../../../spend/domain/models/mono_institution.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const SelectBankBottomSheet(),
    );
  }
}

class _SelectBankBottomSheetState extends ConsumerState<SelectBankBottomSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Listen to search input changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  /// Filter institutions based on search query
  List<MonoInstitution> _filterInstitutions(
    List<MonoInstitution> institutions,
  ) {
    if (_searchQuery.isEmpty) {
      return institutions;
    }

    return institutions.where((institution) {
      final name = institution.institution.toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

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
              icon: const Icon(Icons.close),
            ),
          ),
          const Gap(16),
          CustomTextFormField(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearSearch,
                  )
                : null,
            isRounded: true,
            controller: _searchController,
            hint: 'Search 1,000+ institutions',
            textInputAction: TextInputAction.search,
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchQuery.isEmpty ? 'Popular banks' : 'Search results',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_searchQuery.isNotEmpty)
                Text(
                  '${_filterInstitutions(banksAsync.value ?? []).length} results',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          const Gap(16),
          Expanded(
            child: banksAsync.when(
              skipLoadingOnRefresh: false,
              data: (institutions) {
                final filteredInstitutions = _filterInstitutions(institutions);

                // Show "no results" message if search yields nothing
                if (filteredInstitutions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const Gap(16),
                        Text(
                          'No banks found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try searching with a different keyword'
                              : 'No banks available at the moment',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const Gap(16),
                          TextButton.icon(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Clear search'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView(
                  children: [
                    GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(
                        filteredInstitutions.length,
                        (index) => _buildBankCard(filteredInstitutions[index]),
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
              loading: () =>
                  const CustomLoadingWidget(text: 'Fetching banks...'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(MonoInstitution institution) {
    return CustomCard(
      onTap: () {
        context.pop();
        SelectedBankLoginBottomSheet.show(context, institution: institution);
      },
      borderRadius: 8,
      child: Center(
        child: Text(
          institution.institution,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
// import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/selected_bank_login_bottom_sheet.dart';
// import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';

// import '../../../../../../core/widgets/custom_error_widget.dart';
// import '../../../../../spend/domain/models/mono_institution.dart';

// class SelectBankBottomSheet extends ConsumerStatefulWidget {
//   const SelectBankBottomSheet({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _SelectBankBottomSheetState();

//   static void show(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => SelectBankBottomSheet(),
//     );
//   }
// }

// class _SelectBankBottomSheetState extends ConsumerState<SelectBankBottomSheet> {
//   final _searchController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final banksAsync = ref.watch(institutionsProvider);

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SectionTitleWidget(
//             title: 'Add account',
//             actionWidget: IconButton(
//               onPressed: () => context.pop(),
//               style: Constants.collapsedButtonStyle,
//               icon: Icon(Icons.close),
//             ),
//           ),
//           const Gap(16),
//           CustomTextFormField(
//             prefixIcon: Icon(Icons.search),
//             isRounded: true,
//             controller: _searchController,
//             hint: 'Search 1,000+ institutions',
//           ),
//           const Gap(16),
//           Text(
//             'Popular banks',
//             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//           ),
//           const Gap(16),
//           Expanded(
//             child: banksAsync.when(
//               skipLoadingOnRefresh: false,
//               data: (institutions) {
//                 return ListView(
//                   children: [
//                     GridView.count(
//                       crossAxisCount: 4,
//                       mainAxisSpacing: 16,
//                       crossAxisSpacing: 16,
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       children: List.generate(
//                         institutions.length,
//                         (index) => _buildBankCard(institutions[index]),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//               error: (error, stackTrace) => CustomErrorWidget.error(
//                 onRetry: () {
//                   ref.invalidate(institutionsProvider);
//                 },
//               ),
//               loading: () =>
//                   const CustomLoadingWidget(text: 'Fetching banks...'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBankCard(MonoInstitution institution) {
//     return CustomCard(
//       onTap: () {
//         context.pop();
//         SelectedBankLoginBottomSheet.show(context, institution: institution);
//       },
//       borderRadius: 8,
//       child: Center(
//         child: Text(
//           institution.institution,
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }
