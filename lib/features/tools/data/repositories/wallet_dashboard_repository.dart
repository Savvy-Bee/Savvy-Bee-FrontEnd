// lib/features/wallet/data/wallet_dashboard_repository.dart
//
// Repository + domain models for:
//   GET /wallet/details/dashboard
//
// Note: Balance is stored in kobo by the API — divide by 100 for naira display.

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DOMAIN MODELS
// ═════════════════════════════════════════════════════════════════════════════

/// Which wallet currencies the user has opened.
class WalletAccountExistence {
  final bool ng;
  final bool us;

  const WalletAccountExistence({required this.ng, required this.us});

  factory WalletAccountExistence.fromJson(Map<String, dynamic> json) =>
      WalletAccountExistence(
        ng: json['Ng'] as bool? ?? false,
        us: json['US'] as bool? ?? false,
      );
}

/// Virtual account details for the NGN wallet.
class WalletNgnAccount {
  final String accountName;
  final String accountNumber;
  final String bankCode;
  final String bankName;
  final String koraRef;

  const WalletNgnAccount({
    required this.accountName,
    required this.accountNumber,
    required this.bankCode,
    required this.bankName,
    required this.koraRef,
  });

  factory WalletNgnAccount.fromJson(Map<String, dynamic> json) =>
      WalletNgnAccount(
        accountName:   json['AccountName']   as String? ?? '',
        accountNumber: json['AccountNumber'] as String? ?? '',
        bankCode:      json['BankCode']      as String? ?? '',
        bankName:      json['BankName']      as String? ?? '',
        koraRef:       json['KoraRef']       as String? ?? '',
      );
}

/// The wallet account record.
/// [balanceKobo] is the raw value from the API (in kobo).
/// Use [balanceNaira] for display.
class WalletAccount {
  final String id;
  final String userId;

  /// Raw balance in kobo (as returned by the API).
  final double balanceKobo;

  final DateTime createdAt;
  final DateTime updatedAt;
  final WalletNgnAccount? ngnAccount;

  const WalletAccount({
    required this.id,
    required this.userId,
    required this.balanceKobo,
    required this.createdAt,
    required this.updatedAt,
    this.ngnAccount,
  });

  /// Balance in naira (divide kobo by 100).
  double get balanceNaira => balanceKobo / 100;

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    WalletNgnAccount? ngn;
    if (json['NGNAccount'] != null) {
      ngn = WalletNgnAccount.fromJson(
          json['NGNAccount'] as Map<String, dynamic>);
    }

    return WalletAccount(
      id:          json['_id']    as String? ?? '',
      userId:      json['UserID'] as String? ?? '',
      balanceKobo: ((json['Balance'] as num?) ?? 0).toDouble(),
      createdAt:   DateTime.tryParse(json['createdAt'] as String? ?? '') ??
                   DateTime(0),
      updatedAt:   DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
                   DateTime(0),
      ngnAccount:  ngn,
    );
  }
}

/// Top-level model returned by the dashboard endpoint.
class WalletDashboardData {
  final WalletAccountExistence accountExistence;
  final WalletAccount account;

  const WalletDashboardData({
    required this.accountExistence,
    required this.account,
  });

  factory WalletDashboardData.fromJson(Map<String, dynamic> json) =>
      WalletDashboardData(
        accountExistence: WalletAccountExistence.fromJson(
            json['AccountExistence'] as Map<String, dynamic>),
        account: WalletAccount.fromJson(
            json['Accounts'] as Map<String, dynamic>),
      );

  /// Convenience: naira balance ready for display.
  double get balanceNaira => account.balanceNaira;

  /// Convenience: NGN virtual account (null if not yet created).
  WalletNgnAccount? get ngnAccount => account.ngnAccount;
}

// ═════════════════════════════════════════════════════════════════════════════
// REPOSITORY
// ═════════════════════════════════════════════════════════════════════════════

class WalletDashboardRepository {
  final String bearerToken;
  const WalletDashboardRepository({required this.bearerToken});

  /// GET /wallet/details/dashboard
  Future<WalletDashboardData> fetchDashboard() async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.walletDashboard}'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    print('WalletDashboard: ${response.statusCode} ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String msg = 'Failed to load wallet (${response.statusCode})';
      try {
        final b = jsonDecode(response.body) as Map<String, dynamic>;
        if (b['message'] != null) msg = b['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Wallet dashboard returned success=false');
    }

    return WalletDashboardData.fromJson(body['data'] as Map<String, dynamic>);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RIVERPOD PROVIDERS
// ═════════════════════════════════════════════════════════════════════════════

/// Repository provider — injects the bearer token from the auth provider.
final walletDashboardRepositoryProvider =
    Provider<WalletDashboardRepository>((ref) {
  final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
  return WalletDashboardRepository(bearerToken: token);
});

/// Async data provider — call [ref.watch(walletDashboardProvider)] to get
/// AsyncValue<WalletDashboardData> in any ConsumerWidget.
///
/// To refresh manually:
///   ref.read(walletDashboardProvider.notifier).refresh();
final walletDashboardProvider =
    AsyncNotifierProvider<WalletDashboardNotifier, WalletDashboardData>(
  WalletDashboardNotifier.new,
);

class WalletDashboardNotifier
    extends AsyncNotifier<WalletDashboardData> {
  @override
  Future<WalletDashboardData> build() =>
      ref.read(walletDashboardRepositoryProvider).fetchDashboard();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(walletDashboardRepositoryProvider).fetchDashboard(),
    );
  }
}