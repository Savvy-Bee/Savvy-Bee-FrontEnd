import 'dart:developer';

import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/core/network/models/api_response_model.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
import '../../../../core/network/api_client.dart';

/// Repository for wallet-related operations
class WalletRepository {
  final ApiClient _apiClient;

  WalletRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Create Naira account
  ///
  /// GET /wallet/accountcreation/ng?Pin={pin}
  /// Requires authentication token
  Future<ApiResponse<WalletDashboardData>> createNairaAccount({
    required String pin,
  }) async {
    try {
      final response = await _apiClient.get(
        '/wallet/accountcreation/ng',
        queryParameters: {'Pin': pin},
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => WalletDashboardData.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch spend dashboard data
  ///
  /// GET /wallet/details/dashboard
  /// Requires authentication token
  ///
  /// Returns account existence status and account details including:
  /// - AccountExistence (Ng, US flags)
  /// - Account balance
  /// - NGN account details (AccountName, AccountNumber, BankCode, etc.)
  Future<ApiResponse<WalletDashboardData>> fetchDashboardData() async {
    try {
      final response = await _apiClient.get('/wallet/details/dashboard');

      return ApiResponse.fromJson(
        response.data,
        (data) {
          try {
            return WalletDashboardData.fromJson(data);
          } catch (e, stack) {
            log('[WalletRepo] fetchDashboardData parse error: $e\nData: $data\n$stack');
            rethrow;
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch transactions with pagination
  ///
  /// GET /wallet/details/transactions?page={page}&limit={limit}
  /// Requires authentication token
  ///
  /// Parameters:
  /// - [page]: Page number (optional, defaults to 1)
  /// - [limit]: Number of items per page (optional, defaults to 10)
  ///
  /// Returns paginated transaction list with:
  /// - Pagination info (total, page, limit, totalPages, hasNextPage, hasPrevPage)
  /// - Transaction data (Amount, Charges, Type, Status, etc.)
  Future<ApiResponse<WalletTransactionsResponse>> fetchTransactions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/wallet/details/transactions',
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      return ApiResponse.fromJson(
        response.data,
        (data) {
          final list = data as List<dynamic>;
          return WalletTransactionsResponse(
            transactions: list
                .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
                .toList(),
            pagination: Pagination(
              total: list.length,
              page: page,
              limit: limit,
              totalPages: 1,
              hasNextPage: false,
              hasPrevPage: false,
            ),
          );
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch transactions and spending analytics for a specific budget category.
  ///
  /// GET /wallet/details/transactions-budget?page=&limit=&budgetId=
  Future<ApiResponse<TransactionsBudgetData>> fetchTransactionsBudget({
    required String budgetId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.transactionsBudget,
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          'budgetId': budgetId,
        },
      );

      log('[WalletRepo] fetchTransactionsBudget $budgetId OK');

      // The response wraps data at the top level alongside pagination,
      // but ApiResponse reads json['data'], which is exactly what we need.
      return ApiResponse.fromJson(
        response.data,
        (data) => TransactionsBudgetData.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      log('[WalletRepo] fetchTransactionsBudget ERROR budgetId=$budgetId: $e');
      rethrow;
    }
  }
}
