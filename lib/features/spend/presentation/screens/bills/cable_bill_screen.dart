import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/bills.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/bottom_sheets/bills_bottom_sheet.dart';
import 'bill_confirmation_screen.dart';

class CableBillScreen extends ConsumerStatefulWidget {
  static const String path = '/cable-bill';
  const CableBillScreen({super.key});

  @override
  ConsumerState<CableBillScreen> createState() => _CableBillScreenState();
}

class _CableBillScreenState extends ConsumerState<CableBillScreen> {
  TvProvider? _selectedProvider;
  TvPlan? _selectedPlan;
  final _cardNumberController = TextEditingController();
  bool _isInitializing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _onContinue() async {
    if (_selectedProvider == null) {
      _showSnack('Please select a provider');
      return;
    }
    if (_selectedPlan == null) {
      _showSnack('Please select a package');
      return;
    }
    if (_cardNumberController.text.trim().isEmpty) {
      _showSnack('Please enter your smart card number');
      return;
    }

    setState(() => _isInitializing = true);
    try {
      final success = await ref.read(tvProvider.notifier).initializeTv(
        phoneNo: _cardNumberController.text.trim(),
        provider: _selectedProvider!.shortName,
        code: _selectedPlan!.code,
      );

      if (!mounted) return;

      if (success) {
        context.pushNamed(
          BillConfirmationScreen.path,
          extra: BillConfirmationData(
            type: BillType.tv,
            network: _selectedProvider!.name,
            phoneNumber: _cardNumberController.text.trim(),
            amount: double.tryParse(_selectedPlan!.amount) ?? 0,
            provider: _selectedProvider!.shortName,
            planCode: _selectedPlan!.code,
            planName: _selectedPlan!.name,
          ),
        );
      } else {
        _showSnack('Failed to initialize TV subscription. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Widget _buildProviderCard(TvProvider provider) {
    final isSelected = _selectedProvider?.shortName == provider.shortName;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedProvider = provider;
            _selectedPlan = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFE0C97F) : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: provider.logo.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: provider.logo,
                        placeholder: (_, __) => _logoFallback(),
                        errorWidget: (_, __, ___) => _logoFallback(),
                      )
                    : _logoFallback(),
              ),
              const Gap(6),
              Text(
                provider.shortName,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'GeneralSans',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoFallback() => Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      shape: BoxShape.circle,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final tvProvidersAsync = ref.watch(tvProvidersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                    const Gap(24),
                    const Text(
                      'Cable TV',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Subscribe to your favourite channels',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'GeneralSans',
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Gap(28),
                    const Text(
                      'Select Provider',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                    const Gap(14),
                    tvProvidersAsync.when(
                      skipLoadingOnRefresh: false,
                      data: (providers) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: providers
                              .map(_buildProviderCard)
                              .toList(),
                        ),
                      ),
                      loading: () => const SizedBox(
                        height: 80,
                        child: Center(
                          child: SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFFC107),
                            ),
                          ),
                        ),
                      ),
                      error: (_, __) => GestureDetector(
                        onTap: () => ref.invalidate(tvProvidersProvider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              const Gap(8),
                              Text(
                                'Failed to load providers — tap to retry',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'GeneralSans',
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Package',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(10),
                          GestureDetector(
                            onTap: _selectedProvider == null
                                ? () => _showSnack(
                                    'Please select a provider first',
                                  )
                                : () {
                                    PackageBottomSheet.show(
                                      context,
                                      billType: BillType.tv,
                                      provider: _selectedProvider!.shortName,
                                      onTvSelect: (plan) {
                                        setState(() => _selectedPlan = plan);
                                      },
                                    );
                                  },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.tv_outlined,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                                const Gap(10),
                                Expanded(
                                  child: Text(
                                    _selectedPlan != null
                                        ? '${_selectedPlan!.name} — ₦${_selectedPlan!.amount}'
                                        : 'Choose a package',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'GeneralSans',
                                      color: _selectedPlan != null
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                          Divider(color: Colors.grey.shade100, height: 1),
                          const Gap(16),
                          Text(
                            'Smart Card Number',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Icon(
                                Icons.credit_card_outlined,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                              const Gap(10),
                              Expanded(
                                child: TextField(
                                  controller: _cardNumberController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'GeneralSans',
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter card number',
                                    hintStyle: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'GeneralSans',
                                      color: Colors.grey.shade400,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_selectedPlan != null) ...[
                            const Gap(16),
                            Divider(color: Colors.grey.shade100, height: 1),
                            const Gap(12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Amount',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'GeneralSans',
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  '₦${_selectedPlan!.amount}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'GeneralSans',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Gap(32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isInitializing ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isInitializing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GeneralSans',
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
