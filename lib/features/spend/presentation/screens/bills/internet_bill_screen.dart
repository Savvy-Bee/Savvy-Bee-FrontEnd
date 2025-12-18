import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/input_validator.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_confirmation_screen.dart';

import '../../../domain/models/bills.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/bottom_sheets/bills_bottom_sheet.dart';
import '../../widgets/mini_button.dart';

class InternetBillScreen extends ConsumerStatefulWidget {
  static String path = '/internet-bill';
  const InternetBillScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InternetBillScreenState();
}

class _InternetBillScreenState extends ConsumerState<InternetBillScreen> {
  final _serviceProviderController = TextEditingController();
  final _packageController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedProvider;
  String? _selectedPackageCode;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _serviceProviderController.dispose();
    _packageController.dispose();
    _customerIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleNext() async {
    if (_formKey.currentState!.validate()) {
      context.pushNamed(
        BillConfirmationScreen.path,
        extra: BillConfirmationData(
          type: BillType.data,
          network: _selectedProvider ?? '',
          phoneNumber: _customerIdController.text,
          amount: double.tryParse(_amountController.text) ?? 0.0,
          provider: _selectedProvider!,
          planCode: _selectedPackageCode!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataState = ref.watch(dataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: dataState.isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                : MiniButton(onTap: _handleNext, text: 'Next'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextFormField(
              label: 'Service Provider',
              hint: 'Choose a Provider',
              controller: _serviceProviderController,
              prefixIcon: Icon(Icons.circle_outlined, color: AppColors.primary),
              suffixIcon: Icon(Icons.keyboard_arrow_down),
              readOnly: true,
              onTap: () => ServiceProviderBottomSheet.show(
                context,
                onDataSelect: (provider) {
                  setState(() {
                    final providerName = provider.split(' ')[0].split('-')[0];

                    _selectedProvider = providerName;

                    _serviceProviderController.text = provider;
                    // Reset package when provider changes
                    _selectedPackageCode = null;
                    _packageController.clear();
                  });
                },
                billType: BillType.data,
              ),
              validator: (value) =>
                  InputValidator.validateRequired(value, 'Service provider'),
            ),
            const Gap(16),
            CustomTextFormField(
              label: 'Package',
              hint: 'Choose a Package',
              controller: _packageController,
              suffixIcon: Icon(Icons.keyboard_arrow_down),
              readOnly: true,
              onTap: _selectedProvider == null
                  ? () {
                      CustomSnackbar.show(
                        context,
                        'Please select a provider first',
                        position: SnackbarPosition.bottom,
                      );
                    }
                  : () {
                      PackageBottomSheet.show(
                        context,
                        provider: _selectedProvider!,
                        onDataSelect: (plan) {
                          setState(() {
                            _selectedPackageCode = plan.code;
                            _packageController.text =
                                '${plan.package} - ₦${plan.amount}';
                            _amountController.text = plan.amount.toString();
                          });
                        },
                        billType: BillType.data,
                      );
                    },
              validator: (value) =>
                  InputValidator.validateRequired(value, 'Package'),
            ),
            const Gap(16),
            CustomTextFormField(
              label: 'Customer ID',
              hint: 'Customer ID',
              controller: _customerIdController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (value) =>
                  InputValidator.validateRequired(value, 'Customer ID'),
            ),
            const Gap(16),
            CustomTextFormField(
              label: 'Amount',
              hint: 'Enter amount',
              endLabel: 'Balance: ₦11,638.16',
              controller: _amountController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) =>
                  InputValidator.validateRequired(value, 'Amount'),
            ),
          ],
        ),
      ),
    );
  }
}

// class PackageBottomSheet extends ConsumerStatefulWidget {
//   final String provider;
//   final Function(DataPlan) onSelect;

//   const PackageBottomSheet({
//     super.key,
//     required this.provider,
//     required this.onSelect,
//   });

//   @override
//   ConsumerState<PackageBottomSheet> createState() => _PackageBottomSheetState();

//   static void show(
//     BuildContext context, {
//     required String provider,
//     required Function(DataPlan) onSelect,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       showDragHandle: true,
//       builder: (context) =>
//           PackageBottomSheet(provider: provider, onSelect: onSelect),
//     );
//   }
// }

// class _PackageBottomSheetState extends ConsumerState<PackageBottomSheet> {
//   String _selectedCategory = 'Daily';

//   @override
//   Widget build(BuildContext context) {
//     final dataPlansAsync = ref.watch(dataPlansProvider(widget.provider));

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Choose a Package',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const Gap(16),
//           Text('Categories', style: TextStyle(fontSize: 12)),
//           const Gap(16),
//           Row(
//             spacing: 8,
//             children: [
//               _buildCategoryTile('Daily', _selectedCategory == 'Daily', () {
//                 setState(() => _selectedCategory = 'Daily');
//               }),
//               _buildCategoryTile('Weekly', _selectedCategory == 'Weekly', () {
//                 setState(() => _selectedCategory = 'Weekly');
//               }),
//               _buildCategoryTile('Monthly', _selectedCategory == 'Monthly', () {
//                 setState(() => _selectedCategory = 'Monthly');
//               }),
//               _buildCategoryTile('Yearly', _selectedCategory == 'Yearly', () {
//                 setState(() => _selectedCategory = 'Yearly');
//               }),
//             ],
//           ),
//           const Gap(16),
//           Text('Packages', style: TextStyle(fontSize: 12)),
//           const Gap(16),
//           Flexible(
//             child: ListView(
//               shrinkWrap: true,
//               children: [
//                 dataPlansAsync.when(
//                   data: (plans) {
//                     // Filter plans by category if needed
//                     final filteredPlans = plans
//                         .where(
//                           (plan) => plan.package.contains(_selectedCategory),
//                         )
//                         .toList();

//                     if (filteredPlans.isEmpty) {
//                       return Center(
//                         child: Padding(
//                           padding: const EdgeInsets.all(24.0),
//                           child: Text('No packages available'),
//                         ),
//                       );
//                     }

//                     return Column(
//                       children: filteredPlans.map((plan) {
//                         return Column(
//                           children: [
//                             _buildPackageTile(
//                               '${plan.package} - ₦${plan.amount}',
//                               () {
//                                 widget.onSelect(plan);
//                                 context.pop();
//                               },
//                             ),
//                             if (plan != filteredPlans.last)
//                               const Divider(height: 20),
//                           ],
//                         );
//                       }).toList(),
//                     );
//                   },
//                   loading: () =>
//                       CustomLoadingWidget(text: 'Loading packages...'),
//                   error: (error, stack) => CustomErrorWidget(
//                     subtitle: error.toString(),
//                     onActionPressed: () =>
//                         ref.invalidate(dataPlansProvider(widget.provider)),
//                   ),
//                 ),
//                 const Gap(24),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryTile(String title, bool isSelected, VoidCallback onTap) {
//     return Expanded(
//       child: CustomCard(
//         onTap: onTap,
//         borderRadius: 8,
//         borderColor: isSelected ? AppColors.primary : null,
//         child: Text(
//           title,
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//         ),
//       ),
//     );
//   }

//   Widget _buildPackageTile(String name, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Row(
//         spacing: 16,
//         children: [
//           CircleAvatar(),
//           Expanded(child: Text(name, style: TextStyle(fontSize: 12))),
//         ],
//       ),
//     );
//   }
// }

// class ServiceProviderBottomSheet extends StatelessWidget {
//   final Function(String) onSelect;

//   const ServiceProviderBottomSheet({super.key, required this.onSelect});

//   @override
//   Widget build(BuildContext context) {
//     final providers = [
//       'MTN-NG DATA',
//       'AIRTEL NG DATA',
//       'GLO NG DATA',
//       '9MOBILE NG DATA',
//     ];

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Choose a Provider',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const Gap(16),
//           ...providers.map((provider) {
//             return Column(
//               children: [
//                 _buildServiceProviderTile(provider, () {
//                   onSelect(provider);
//                   Navigator.pop(context);
//                 }),
//                 if (provider != providers.last) const Divider(height: 20),
//               ],
//             );
//           }),
//           const Gap(24),
//         ],
//       ),
//     );
//   }

//   Widget _buildServiceProviderTile(String name, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Row(
//         spacing: 16,
//         children: [
//           CircleAvatar(),
//           Text(name, style: TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   static void show(BuildContext context, {required Function(String) onSelect}) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       showDragHandle: true,
//       builder: (context) => ServiceProviderBottomSheet(onSelect: onSelect),
//     );
//   }
// }
