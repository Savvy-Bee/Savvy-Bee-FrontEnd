import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/models/api_response_model.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/savings.dart';

/// Repository for Goals/Savings operations
class GoalsRepository {
  final ApiClient apiClient;

  GoalsRepository({required this.apiClient});

  /// Fetch all savings goals
  /// GET /tools/savings/home
  Future<ApiResponse<List<SavingsGoal>>> getHomeData() async {
    try {
      final response = await apiClient.get('/tools/savings/home');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final dataList = responseData['data'] as List;

        final goals = dataList
            .map((json) => SavingsGoal.fromJson(json as Map<String, dynamic>))
            .toList();

        return ApiResponse(
          success: responseData['success'] as bool,
          message: responseData['message'] as String,
          data: goals,
        );
      } else {
        throw ApiException(
          message: 'Failed to fetch savings goals',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch savings goals: $e');
    }
  }

  /// Create a new savings goal
  /// POST /tools/savings/create
  ///
  /// Parameters:
  /// - [name]: Name of the savings goal
  /// - [totalSavings]: Target amount to save
  /// - [amountSaved]: Initial amount to deposit (will be deducted from wallet)
  /// - [endDate]: Target end date (format: YYYY-MM-DD)
  Future<ApiResponse<SavingsGoal>> createSavings({
    required String name,
    required double totalSavings,
    required double amountSaved,
    required String endDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        'Name': name,
        'TotalSavings': totalSavings.toString(),
        'Amountsaved': amountSaved.toString(),
        'enddate': endDate,
      });

      final response = await apiClient.post(
        '/tools/savings/create',
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final dataList = responseData['data'] as List;
        final goal = SavingsGoal.fromJson(
          dataList.first as Map<String, dynamic>,
        );

        return ApiResponse(
          success: responseData['success'] as bool,
          message: responseData['message'] as String,
          data: goal,
        );
      } else {
        throw ApiException(
          message: 'Failed to create savings goal',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to create savings goal: $e');
    }
  }

  /// Add funds to a savings goal
  /// PATCH /tools/savings/funds/credit/:id
  ///
  /// Parameters:
  /// - [goalId]: ID of the savings goal
  /// - [amount]: Amount to add to the savings
  Future<ApiResponse<SavingsGoal>> addFunds({
    required String goalId,
    required double amount,
  }) async {
    try {
      final formData = FormData.fromMap({'amountSpent': amount.toString()});

      final response = await apiClient.patch(
        '/tools/savings/funds/credit/$goalId',
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final goal = SavingsGoal.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );

        return ApiResponse(
          success: responseData['success'] as bool,
          message: responseData['message'] as String,
          data: goal,
        );
      } else {
        throw ApiException(
          message: 'Failed to add funds to savings',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to add funds to savings: $e');
    }
  }

  /// Withdraw funds from a savings goal
  /// PATCH /tools/savings/funds/debit/:id
  ///
  /// Parameters:
  /// - [goalId]: ID of the savings goal
  /// - [amount]: Amount to withdraw from the savings
  Future<ApiResponse<SavingsGoal>> withdrawFunds({
    required String goalId,
    required double amount,
  }) async {
    try {
      final formData = FormData.fromMap({'amountSpent': amount.toString()});

      final response = await apiClient.patch(
        '/tools/savings/funds/debit/$goalId',
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final goal = SavingsGoal.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );

        return ApiResponse(
          success: responseData['success'] as bool,
          message: responseData['message'] as String,
          data: goal,
        );
      } else {
        throw ApiException(
          message: 'Failed to withdraw funds from savings',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to withdraw funds from savings: $e');
    }
  }
}
