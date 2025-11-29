import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/bills.dart';
import '../../../../core/network/api_client.dart';

/// Repository for handling all bill payment operations
class BillsRepository {
  final ApiClient _apiClient;

  BillsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // ==================== AIRTIME ====================

  /// Initialize airtime purchase
  ///
  /// [phoneNo] - Phone number to recharge (e.g., +2347030000000)
  /// [provider] - Network provider: "MTN", "GLO", "9MOBILE", "AIRTEL"
  /// [amount] - Amount to purchase (e.g., "100")
  Future<BillsResponse> initializeAirtime({
    required String phoneNo,
    required String provider,
    required String amount,
  }) async {
    try {
      final formData = FormData.fromMap({
        'PhoneNo': phoneNo,
        'Provider': provider,
        'Amount': amount,
      });

      final response = await _apiClient.post(
        ApiEndpoints.initializeAirtime,
        data: formData,
      );

      return BillsResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to initialize airtime: $e');
    }
  }

  /// Verify airtime transaction with PIN
  ///
  /// [pin] - User's transaction PIN (e.g., "1234")
  Future<BillsResponse> verifyAirtime({required String pin}) async {
    try {
      final formData = FormData.fromMap({'Pin': pin});

      final response = await _apiClient.post(
        ApiEndpoints.verifyAirtimeTransaction,
        data: formData,
      );

      return BillsResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to verify airtime: $e');
    }
  }

  // ==================== DATA ====================

  /// Fetch available data plans for a provider
  ///
  /// [provider] - Network provider: "MTN", "GLO", "ETISALAT", "AIRTEL", "SMILE", "SPECTRANET"
  Future<List<DataPlan>> fetchDataPlans({required String provider}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.fetchDataPlans,
        queryParameters: {'Provider': provider},
      );

      final billResponse = BillsResponse.fromJson(response.data);

      if (billResponse.data is List) {
        return (billResponse.data as List)
            .map((plan) => DataPlan.fromJson(plan))
            .toList();
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch data plans: $e');
    }
  }

  /// Initialize data purchase
  ///
  /// [phoneNo] - Phone number to recharge (e.g., +2348133092341)
  /// [provider] - Network provider: "MTN", "GLO", "ETISALAT", "AIRTEL", "SMILE", "SPECTRANET"
  /// [code] - Plan code from fetchDataPlans (e.g., "MTN-1")
  Future<BillsResponse> initializeData({
    required String phoneNo,
    required String provider,
    required String code,
  }) async {
    try {
      final formData = FormData.fromMap({
        'PhoneNo': phoneNo,
        'Provider': provider,
        'Code': code,
      });

      final response = await _apiClient.post(
        ApiEndpoints.initializeDataPurchase,
        data: formData,
      );

      return BillsResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to initialize data: $e');
    }
  }

  /// Verify data transaction with PIN
  ///
  /// [pin] - User's transaction PIN (e.g., "1234")
  Future<BillsResponse> verifyData({required String pin}) async {
    try {
      final formData = FormData.fromMap({'Pin': pin});

      final response = await _apiClient.post(
        ApiEndpoints.verifyDataTransaction,
        data: formData,
      );

      return BillsResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to verify data: $e');
    }
  }

  // ==================== TV BILLS ====================

  /// Fetch available TV providers
  Future<List<TvProvider>> fetchTvProviders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.fetchTVProviders);

      final billResponse = BillsResponse.fromJson(response.data);

      if (billResponse.data is List) {
        return (billResponse.data as List)
            .map((provider) => TvProvider.fromJson(provider))
            .toList();
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch TV providers: $e');
    }
  }

  /// Fetch available TV plans for a provider
  ///
  /// [provider] - TV provider: "DSTV", "GOTV", "STARTIMES"
  Future<List<TvPlan>> fetchTvPlans({required String provider}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.fetchTVPlans,
        queryParameters: {'Provider': provider},
      );

      final billResponse = BillsResponse.fromJson(response.data);

      if (billResponse.data is List) {
        return (billResponse.data as List)
            .map((plan) => TvPlan.fromJson(plan))
            .toList();
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch TV plans: $e');
    }
  }

  /// Initialize TV subscription
  ///
  /// [phoneNo] - Phone number
  /// [provider] - TV provider: "DSTV", "GOTV", "STARTIMES"
  /// [code] - Plan code from fetchTvPlans (e.g., "dstv-7")
  Future<BillsResponse> initializeTv({
    required String phoneNo,
    required String provider,
    required String code,
  }) async {
    try {
      final formData = FormData.fromMap({
        'PhoneNo': phoneNo,
        'Provider': provider,
        'Code': code,
      });

      final response = await _apiClient.post(
        ApiEndpoints.initializeTVSubscription,
        data: formData,
      );

      return BillsResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to initialize TV subscription: $e');
    }
  }

  /// Verify TV transaction with PIN
  ///
  /// [pin] - User's transaction PIN (e.g., "1234")
  Future<BillsResponse> verifyTv({required String pin}) async {
    try {
      final formData = FormData.fromMap({'Pin': pin});

      final response = await _apiClient.post(
        ApiEndpoints.verifyTVSubscription,
        data: formData,
      );

      return BillsResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to verify TV subscription: $e');
    }
  }

  // ==================== ELECTRICITY BILLS ====================

  /// Fetch available electricity providers
  Future<List<ElectricityProvider>> fetchElectricityProviders() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.fetchEletricityProviders,
      );

      final billResponse = BillsResponse.fromJson(response.data);

      if (billResponse.data is List) {
        return (billResponse.data as List)
            .map((provider) => ElectricityProvider.fromJson(provider))
            .toList();
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch electricity providers: $e');
    }
  }

  /// Initialize and validate electricity bill details
  ///
  /// [phoneNo] - Phone number
  /// [provider] - Electricity provider short name (e.g., "IKEDC", "EKEDC")
  /// [code] - Meter number or customer code
  /// [amount] - Amount to pay
  /// [meterType] - Meter type: "prepaid" or "postpaid"
  Future<BillsResponse> initializeElectricity({
    required String phoneNo,
    required String provider,
    required String code,
    required String amount,
    String meterType = 'prepaid',
  }) async {
    try {
      final formData = FormData.fromMap({
        'PhoneNo': phoneNo,
        'Provider': provider,
        'Code': code,
        'Amount': amount,
        'MeterType': meterType,
      });

      final response = await _apiClient.post(
        ApiEndpoints.initializeElectricity,
        data: formData,
      );

      return BillsResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to initialize electricity bill: $e');
    }
  }

  /// Verify electricity transaction with PIN
  ///
  /// [pin] - User's transaction PIN (e.g., "1234")
  Future<BillsResponse> verifyElectricity({required String pin}) async {
    try {
      final formData = FormData.fromMap({'Pin': pin});

      final response = await _apiClient.post(
        ApiEndpoints.verifyElectricity,
        data: formData,
      );

      return BillsResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to verify electricity bill: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Set authentication token for all requests
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear authentication token
  void clearAuthToken() {
    _apiClient.clearAuthToken();
  }
}
