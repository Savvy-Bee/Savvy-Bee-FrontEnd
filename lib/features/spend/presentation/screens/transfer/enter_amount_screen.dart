import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/currency_input_formatter.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';

import 'review_screen.dart';
import 'send_money_screen.dart';

const List<String> _transferForCategories = [
  'Auto & transport',
  'Childcare & education',
  'Drinks & dining',
  'Entertainment',
  'Financial',
  'Groceries',
  'Healthcare',
  'Household',
  'Other',
  'Personal care',
  'Shopping',
  'Income',
  'Bills & Utilities',
];

String _getCategoryIconPath(String categoryName) {
  switch (categoryName.trim().toLowerCase()) {
    case 'auto & transport':
      return 'assets/images/icons/budget categories/Auto & Transport.png';
    case 'childcare & education':
      return 'assets/images/icons/budget categories/Childcare & Education.png';
    case 'drinks & dining':
      return 'assets/images/icons/budget categories/Drinks & Dining.png';
    case 'entertainment':
      return 'assets/images/icons/budget categories/Entertainment.png';
    case 'financial':
      return 'assets/images/icons/budget categories/Financial.png';
    case 'groceries':
      return 'assets/images/icons/budget categories/Groceries.png';
    case 'healthcare':
      return 'assets/images/icons/budget categories/Healthcare.png';
    case 'household':
      return 'assets/images/icons/budget categories/Household.png';
    case 'other':
      return 'assets/images/icons/budget categories/Other.png';
    case 'personal care':
      return 'assets/images/icons/budget categories/Personal Care.png';
    case 'shopping':
      return 'assets/images/icons/budget categories/Shopping.png';
    default:
      return 'assets/images/icons/budget_category.png';
  }
}

class EnterAmountScreen extends ConsumerStatefulWidget {
  static const String path = '/enter-amount';

  final RecipientAccountInfo recipientAccountInfo;

  const EnterAmountScreen({super.key, required this.recipientAccountInfo});

  @override
  ConsumerState<EnterAmountScreen> createState() => _EnterAmountScreenState();
}

class _EnterAmountScreenState extends ConsumerState<EnterAmountScreen> {
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();
  final _amountFocus = FocusNode();
  final _narrationFocus = FocusNode();
  String? _selectedFor;

  @override
  void dispose() {
    _amountController.dispose();
    _narrationController.dispose();
    _amountFocus.dispose();
    _narrationFocus.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _amountController.text.trim().isNotEmpty &&
      _selectedFor != null &&
      _narrationController.text.trim().isNotEmpty;

  void _onContinue() {
    context.pushNamed(
      ReviewScreen.path,
      extra: TransferAmountArgs(
        recipientAccountInfo: widget.recipientAccountInfo,
        amount: _amountController.text,
        transferFor: _selectedFor!,
        narration: _narrationController.text.trim(),
      ),
    );
  }

  Future<void> _showForPicker() async {
    FocusScope.of(context).unfocus();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CategoryPickerSheet(selected: _selectedFor),
    );
    if (selected != null) {
      setState(() => _selectedFor = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Amount',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(20),
                Text(
                  'How much to ${widget.recipientAccountInfo.accountName}?',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const Spacer(),

                // Amount input
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '₦',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          focusNode: _amountFocus,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d,.]'),
                            ),
                            CurrencyInputFormatter(),
                          ],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            letterSpacing: -2,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade300,
                              letterSpacing: -2,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(12),
                Center(
                  child: dashboardAsync.when(
                    data: (data) => Text(
                      'Available: ${data.data?.accounts.balance.formatCurrency(decimalDigits: 0) ?? ''}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF757575),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                const Gap(20),

                // For selector
                GestureDetector(
                  onTap: _showForPicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedFor ?? 'What is this for?',
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedFor != null
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                  ),
                ),

                const Gap(12),

                // Narration input
                TextField(
                  controller: _narrationController,
                  focusNode: _narrationFocus,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: 'Add a narration',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black54),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    counterText: '',
                  ),
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  onChanged: (_) => setState(() {}),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canContinue ? _onContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      disabledBackgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _canContinue ? Colors.black : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                const Gap(30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  final String? selected;

  const _CategoryPickerSheet({this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'What is this for?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Gap(8),
          const Divider(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _transferForCategories.length,
              itemBuilder: (context, index) {
                final category = _transferForCategories[index];
                final isSelected = category == selected;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    radius: 20,
                    child: Image.asset(
                      _getCategoryIconPath(category),
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.category_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    category,
                    style: const TextStyle(fontSize: 15),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFFFFC107))
                      : null,
                  onTap: () => Navigator.of(context).pop(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
