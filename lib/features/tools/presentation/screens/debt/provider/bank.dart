import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/service/paystack.dart';

final paystackServiceProvider = Provider(
  (ref) => PaystackService('sk_test_475c71d2424f9d6dd7534cf6a21a9e9042743e51'),
);

final bankListProvider = FutureProvider<List<Map<String, String>>>((ref) {
  return ref.read(paystackServiceProvider).fetchBanks();
});

final accountResolutionProvider =
    FutureProvider.family<String, ({String bankCode, String accNumber})>(
        (ref, params) {
  return ref.read(paystackServiceProvider).resolveAccount(
        bankCode: params.bankCode,
        accountNumber: params.accNumber,
      );
});