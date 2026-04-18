import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/beneficiary.dart';

class BeneficiaryNotifier extends StateNotifier<List<Beneficiary>> {
  BeneficiaryNotifier() : super([]) {
    _load();
  }

  static const _prefsKey = 'beneficiaries';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => Beneficiary.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(state.map((b) => b.toJson()).toList()),
    );
  }

  Future<void> add(Beneficiary beneficiary) async {
    final alreadyExists = state.any(
      (b) =>
          (b.accountNumber != null &&
              b.accountNumber == beneficiary.accountNumber) ||
          (b.username != null && b.username == beneficiary.username),
    );
    if (alreadyExists) return;
    state = [...state, beneficiary];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((b) => b.id != id).toList();
    await _persist();
  }
}

final beneficiaryProvider =
    StateNotifierProvider<BeneficiaryNotifier, List<Beneficiary>>(
  (_) => BeneficiaryNotifier(),
);
