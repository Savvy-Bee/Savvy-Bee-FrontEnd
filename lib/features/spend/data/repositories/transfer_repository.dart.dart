import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/account_verification.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/bank.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/internal_transfer.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/transaction.dart';

class TransferRepository {
  final ApiClient _apiClient;

  TransferRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all banks
  Future<BanksResponse> getBanks() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.banks);

      return BanksResponse.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch banks: $e');
    }
  }

  /// Verify account details before transfer
  Future<AccountVerificationResponse> verifyAccount({
    required String accountNumber,
    required String bankName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'AcctNumber': accountNumber,
        'Bankname': bankName,
      });

      final response = await _apiClient.post(
        ApiEndpoints.verifyAccounts,
        data: formData,
      );

      return AccountVerificationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to verify account: $e');
    }
  }

  /// Initialize external bank transfer
  Future<Map<String, dynamic>> initializeTransaction({
    required String accountNumber,
    required String bankCode,
    required double amount,
  }) async {
    try {
      final formData = FormData.fromMap({
        'AcctNumber': accountNumber,
        'BankCode': bankCode,
        'Amount': amount.toString(),
      });

      final response = await _apiClient.post(
        ApiEndpoints.initializeTransaction,
        data: formData,
      );

      return response.data as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to initialize transaction: $e');
    }
  }

  /// Complete external bank transfer with PIN verification
  Future<TransactionResponse> verifyTransaction({
    required String pin,
    required String transferFor,
    required String narration,
  }) async {
    try {
      final formData = FormData.fromMap({
        'Pin': pin,
        'For': transferFor,
        'Narration': narration,
      });

      final response = await _apiClient.post(
        ApiEndpoints.verifyTransaction,
        data: formData,
      );

      return TransactionResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to verify transaction: $e');
    }
  }

  /// Send money internally to another user within the app
  Future<InternalTransferResponse> sendMoneyInternally({
    required String pin,
    required String transferFor,
    required String narration,
    required String username,
    required double amount,
  }) async {
    try {
      final formData = FormData.fromMap({
        'Pin': pin,
        'For': transferFor,
        'Narration': narration,
        'Username': username,
        'Amount': amount.toString(),
      });

      final response = await _apiClient.post(
        ApiEndpoints.sendMoneyInternally,
        data: formData,
      );

      return InternalTransferResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to send money internally: $e');
    }
  }
}
