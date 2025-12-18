import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/custom_card.dart';
import '../../../../../core/widgets/custom_error_widget.dart';
import '../../../../../core/widgets/custom_loading_widget.dart';
import '../../../domain/models/bills.dart';
import '../../providers/bill_provider.dart';

enum BillType { airtime, data, tv, electricity }

class PackageBottomSheet extends ConsumerStatefulWidget {
  final BillType billType;
  final String provider; // Provider code/name
  final Function(DataPlan)? onDataSelect;
  final Function(TvPlan)? onTvSelect;

  const PackageBottomSheet({
    super.key,
    required this.billType,
    required this.provider,
    this.onDataSelect,
    this.onTvSelect,
  });

  @override
  ConsumerState<PackageBottomSheet> createState() => _PackageBottomSheetState();

  static void show(
    BuildContext context, {
    required BillType billType,
    required String provider,
    Function(DataPlan)? onDataSelect,
    Function(TvPlan)? onTvSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => PackageBottomSheet(
        billType: billType,
        provider: provider,
        onDataSelect: onDataSelect,
        onTvSelect: onTvSelect,
      ),
    );
  }
}

class _PackageBottomSheetState extends ConsumerState<PackageBottomSheet> {
  String _selectedCategory = 'Daily';

  @override
  Widget build(BuildContext context) {
    // Fetch plans based on bill type
    final plansAsync = widget.billType == BillType.data
        ? ref.watch(dataPlansProvider(widget.provider))
        : widget.billType == BillType.tv
        ? ref.watch(tvPlansProvider(widget.provider))
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose a Package',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Gap(16),
          Text('Categories', style: TextStyle(fontSize: 12)),
          const Gap(16),
          Row(
            spacing: 8,
            children: [
              _buildCategoryTile('Daily', _selectedCategory == 'Daily', () {
                setState(() => _selectedCategory = 'Daily');
              }),
              _buildCategoryTile('Weekly', _selectedCategory == 'Weekly', () {
                setState(() => _selectedCategory = 'Weekly');
              }),
              _buildCategoryTile('Monthly', _selectedCategory == 'Monthly', () {
                setState(() => _selectedCategory = 'Monthly');
              }),
              _buildCategoryTile('Yearly', _selectedCategory == 'Yearly', () {
                setState(() => _selectedCategory = 'Yearly');
              }),
            ],
          ),
          const Gap(16),
          Text('Packages', style: TextStyle(fontSize: 12)),
          const Gap(16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (plansAsync != null)
                  plansAsync.when(
                    skipLoadingOnRefresh: false,
                    data: (plans) {
                      if (widget.billType == BillType.data) {
                        return _buildDataPlansList(plans as List<DataPlan>);
                      } else if (widget.billType == BillType.tv) {
                        return _buildTvPlansList(plans as List<TvPlan>);
                      }
                      return Center(child: Text('Unsupported bill type'));
                    },
                    loading: () =>
                        CustomLoadingWidget(text: 'Loading packages...'),
                    error: (error, stack) => CustomErrorWidget.error(
                      title: 'Failed to fetch packages',
                      subtitle: error.toString(),
                      onRetry: () {
                        if (widget.billType == BillType.data) {
                          ref.invalidate(dataPlansProvider(widget.provider));
                        } else if (widget.billType == BillType.tv) {
                          ref.invalidate(tvPlansProvider(widget.provider));
                        }
                      },
                    ),
                  )
                else
                  Center(child: Text('No plans available')),
                const Gap(24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPlansList(List<DataPlan> plans) {
    // Filter plans by category
    final filteredPlans = plans
        .where((plan) => plan.package.contains(_selectedCategory))
        .toList();

    if (filteredPlans.isEmpty) {
      return CustomErrorWidget.empty(
        title: 'No packages available',
        subtitle: 'Try a different category',
      );
    }

    return Column(
      children: filteredPlans.map((plan) {
        return Column(
          children: [
            _buildPackageTile('${plan.package} - ₦${plan.amount}', () {
              widget.onDataSelect?.call(plan);
              context.pop();
            }),
            if (plan != filteredPlans.last) const Divider(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTvPlansList(List<TvPlan> plans) {
    // Filter plans by category
    final filteredPlans = plans
        .where((plan) => plan.package.contains(_selectedCategory))
        .toList();

    if (filteredPlans.isEmpty) {
      return CustomErrorWidget.empty(
        title: 'No packages available',
        subtitle: 'Try a different category',
      );
    }

    return Column(
      children: filteredPlans.map((plan) {
        return Column(
          children: [
            _buildPackageTile('${plan.name} - ₦${plan.amount}', () {
              widget.onTvSelect?.call(plan);
              context.pop();
            }),
            if (plan != filteredPlans.last) const Divider(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryTile(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: CustomCard(
        onTap: onTap,
        borderRadius: 8,
        borderColor: isSelected ? AppColors.primary : null,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildPackageTile(String name, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        spacing: 16,
        children: [
          CircleAvatar(),
          Expanded(child: Text(name, style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

class ServiceProviderBottomSheet extends ConsumerWidget {
  final BillType billType;
  final Function(String)? onDataSelect; // For data providers (string)
  final Function(TvProvider)? onTvSelect; // For TV providers
  final Function(ElectricityProvider)? onElectricitySelect; // For electricity

  const ServiceProviderBottomSheet({
    super.key,
    required this.billType,
    this.onDataSelect,
    this.onTvSelect,
    this.onElectricitySelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose a Provider',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Gap(16),
          _buildProviderList(context, ref),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildProviderList(BuildContext context, WidgetRef ref) {
    switch (billType) {
      case BillType.data:
        return _buildDataProviders(context);
      case BillType.tv:
        return _buildTvProviders(context, ref);
      case BillType.electricity:
        return _buildElectricityProviders(context, ref);
      default:
        return Center(child: Text('Unsupported bill type'));
    }
  }

  Widget _buildDataProviders(BuildContext context) {
    final providers = [
      'MTN-NG DATA',
      'AIRTEL NG DATA',
      'GLO NG DATA',
      '9MOBILE NG DATA',
    ];

    return Column(
      children: providers.map((provider) {
        return Column(
          children: [
            _buildServiceProviderTile(provider, () {
              onDataSelect?.call(provider);
              Navigator.pop(context);
            }),
            if (provider != providers.last) const Divider(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTvProviders(BuildContext context, WidgetRef ref) {
    final tvProvidersAsync = ref.watch(tvProvidersProvider);

    return tvProvidersAsync.when(
      data: (providers) {
        if (providers.isEmpty) {
          return Center(child: Text('No providers available'));
        }

        return Column(
          children: providers.map((provider) {
            return Column(
              children: [
                _buildServiceProviderTile(
                  provider.name,
                  () {
                    onTvSelect?.call(provider);
                    Navigator.pop(context);
                  },
                  logo: provider.logo.isNotEmpty ? provider.logo : null,
                ),
                if (provider != providers.last) const Divider(height: 20),
              ],
            );
          }).toList(),
        );
      },
      loading: () => CustomLoadingWidget(),
      error: (error, stack) => CustomErrorWidget.error(
        title: 'Failed to fetch TV providers',
        subtitle: error.toString(),
        onRetry: () => ref.invalidate(tvProvidersProvider),
      ),
    );
  }

  Widget _buildElectricityProviders(BuildContext context, WidgetRef ref) {
    final electricityProvidersAsync = ref.watch(electricityProvidersProvider);

    return electricityProvidersAsync.when(
      data: (providers) {
        if (providers.isEmpty) {
          return Center(child: Text('No providers available'));
        }

        return Column(
          children: providers.map((provider) {
            return Column(
              children: [
                _buildServiceProviderTile(
                  provider.disco,
                  () {
                    onElectricitySelect?.call(provider);
                    Navigator.pop(context);
                  },
                  logo: provider.logo.isNotEmpty ? provider.logo : null,
                ),
                if (provider != providers.last) const Divider(height: 20),
              ],
            );
          }).toList(),
        );
      },
      loading: () => CustomLoadingWidget(),
      error: (error, stack) => CustomErrorWidget.error(
        title: 'Failed to fetch electricity providers',
        subtitle: error.toString(),
        onRetry: () => ref.invalidate(electricityProvidersProvider),
      ),
    );
  }

  Widget _buildServiceProviderTile(
    String name,
    VoidCallback onTap, {
    String? logo,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        spacing: 16,
        children: [
          logo != null
              ? CachedNetworkImage(
                  imageUrl: logo,
                  placeholder: (context, url) => CircleAvatar(),
                  errorWidget: (context, url, error) => CircleAvatar(),
                  height: 40,
                )
              : CircleAvatar(),
          Text(name, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required BillType billType,
    Function(String)? onDataSelect,
    Function(TvProvider)? onTvSelect,
    Function(ElectricityProvider)? onElectricitySelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => ServiceProviderBottomSheet(
        billType: billType,
        onDataSelect: onDataSelect,
        onTvSelect: onTvSelect,
        onElectricitySelect: onElectricitySelect,
      ),
    );
  }
}
