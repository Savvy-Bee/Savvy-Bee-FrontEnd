import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
import '../../../../core/network/api_client.dart';

class BudgetRepository {
  final ApiClient _apiClient;

  BudgetRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetches budget home data (TotalEarnings and Budgets list)
  /// Corresponds to [GET /tools/budget/home]
  Future<BudgetHomeData> getBudgetHomeData() async {
    try {
      const String path = '/tools/budget/home';
      final response = await _apiClient.get(path);

      if (response.data['success'] == true && response.data['data'] != null) {
        // Parse the data object using our model
        return BudgetHomeData.fromMap(response.data['data']);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to fetch budget data',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow; // Re-throw if it's already an ApiException
    } catch (e) {
      // Catch any other unexpected errors
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Updates the user's monthly earnings
  /// Corresponds to [POST /tools/budget/updateearnings]
  Future<String> updateMonthlyEarnings(num monthlyEarning) async {
    try {
      const String path = '/tools/budget/updateearnings';

      // Create FormData as specified in Postman
      final formData = FormData.fromMap({
        'MonthlyEarning': monthlyEarning.toString(),
      });

      final response = await _apiClient.post(path, data: formData);

      if (response.data['success'] == true) {
        return response.data['message'] as String;
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to update earnings',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Creates a new budget
  /// Corresponds to [POST /tools/budget/create]
  Future<String> createBudget({
    required String budgetName,
    required num totalBudget,
    required num amountSpent,
  }) async {
    try {
      const String path = '/tools/budget/create';

      // Create FormData as specified in Postman
      final formData = FormData.fromMap({
        'TotalBudget': totalBudget.toString(),
        'BudgetName': budgetName,
        'amountSpent': amountSpent.toString(),
      });

      final response = await _apiClient.post(path, data: formData);

      if (response.data['success'] == true) {
        // Assuming a success message is returned, similar to updateearnings
        return response.data['message'] ?? 'Budget created successfully';
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to create budget',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Updates an existing budget's target amount
  Future<String> updateBudget({
    required String budgetName,
    required num newTargetAmount,
    required num amountSpent,
  }) async {
    try {
      const String path = '/tools/budget/update';

      // **Updated FormData keys based on the provided API spec**
      final formData = FormData.fromMap({
        'BudgetName': budgetName,
        'TotalBudget': newTargetAmount.toString(),
        'amountSpent': amountSpent.toString(),
      });

      final response = await _apiClient.post(path, data: formData);

      // Check for success: true in the response body
      if (response.data['success'] == true) {
        return response.data['message'] ?? 'Budget updated successfully';
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to update budget',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }
}
