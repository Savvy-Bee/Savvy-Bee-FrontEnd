import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
import '../../../../core/network/api_client.dart';

class BudgetRepository {
  final ApiClient _apiClient;

  BudgetRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// GET /tools/budget/home
  /// Fetches budget home data (TotalEarnings and Budgets list)
  Future<BudgetHomeData> getBudgetHomeData() async {
    try {
      const String path = '/tools/budget/home';
      final response = await _apiClient.get(path);

      if (response.data['success'] == true && response.data['data'] != null) {
        return BudgetHomeData.fromMap(response.data['data']);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to fetch budget data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // ✅ CRITICAL: Handle connection error but parse data if available
      if (e.type == DioExceptionType.connectionError &&
          e.response?.data != null &&
          e.response?.data['success'] == true) {
        print('⚠️ Connection error but data received - parsing anyway');
        try {
          return BudgetHomeData.fromMap(e.response!.data['data']);
        } catch (parseError) {
          print('❌ Failed to parse data from error response: $parseError');
          throw ApiException(
            message: 'Network error: Connection reset while reading response',
            statusCode: 0,
          );
        }
      }

      if (e.type == DioExceptionType.connectionError) {
        throw ApiException(
          message:
              'Network connection error. Please check your internet and try again.',
          statusCode: 0,
        );
      }

      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// POST /tools/budget/updateearnings
  /// Updates the user's monthly earnings
  Future<String> updateMonthlyEarnings(num monthlyEarning) async {
    try {
      const String path = '/tools/budget/updateearnings';

      final formData = FormData.fromMap({
        'MonthlyEarning': monthlyEarning.toString(),
      });

      final response = await _apiClient.post(path, data: formData);

      if (response.data['success'] == true) {
        return response.data['message'] as String? ??
            'Monthly income updated successfully';
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

  /// POST /tools/budget/create
  /// Creates a new budget category
  Future<Budget> createBudget({
    required String budgetName,
    required num totalBudget,
    required num amountSpent,
  }) async {
    try {
      const String path = '/tools/budget/create';

      final formData = FormData.fromMap({
        'TotalBudget': totalBudget.toString(),
        'BudgetName': budgetName,
        'amountSpent': amountSpent.toString(),
      });

      final response = await _apiClient.post(path, data: formData);

      if (response.data['success'] == true) {
        // Return the created budget from response.data['data']
        return Budget.fromMap(response.data['data']);
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

  /// POST /tools/budget/update
  /// Updates an existing budget's target amount
  Future<String> updateBudget({
    required String budgetName,
    required num newTargetAmount,
    required num amountSpent,
  }) async {
    try {
      const String path = '/tools/budget/update';

      final formData = FormData.fromMap({
        'BudgetName': budgetName,
        'TotalBudget': newTargetAmount.toString(),
        'amountSpent': amountSpent.toString(),
      });

      final response = await _apiClient.post(path, data: formData);

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

  /// DELETE /tools/budget/delete (if needed in future)
  /// Deletes a budget category
  Future<String> deleteBudget(String budgetName) async {
    try {
      const String path = '/tools/budget/delete';

      final formData = FormData.fromMap({'BudgetName': budgetName});

      final response = await _apiClient.post(path, data: formData);

      if (response.data['success'] == true) {
        return response.data['message'] ?? 'Budget deleted successfully';
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to delete budget',
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

// import 'package:dio/dio.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
// import '../../../../core/network/api_client.dart';

// class BudgetRepository {
//   final ApiClient _apiClient;

//   BudgetRepository({required ApiClient apiClient}) : _apiClient = apiClient;

//   /// Fetches budget home data (TotalEarnings and Budgets list)
//   /// Corresponds to [GET /tools/budget/home]
//   Future<BudgetHomeData> getBudgetHomeData() async {
//     try {
//       const String path = '/tools/budget/home';
//       final response = await _apiClient.get(path);

//       if (response.data['success'] == true && response.data['data'] != null) {
//         // Parse the data object using our model
//         return BudgetHomeData.fromMap(response.data['data']);
//       } else {
//         throw ApiException(
//           message: response.data['message'] ?? 'Failed to fetch budget data',
//           statusCode: response.statusCode,
//         );
//       }
//     } on DioException catch (e) {
//       // ✅ CRITICAL FIX: Check if we have data despite connection error
//       if (e.type == DioExceptionType.connectionError &&
//           e.response?.data != null &&
//           e.response?.data['success'] == true) {
//         print('⚠️ Connection error but data received - parsing anyway');

//         try {
//           return BudgetHomeData.fromMap(e.response!.data['data']);
//         } catch (parseError) {
//           print('❌ Failed to parse data from error response: $parseError');
//           throw ApiException(
//             message: 'Network error: Connection reset while reading response',
//             statusCode: 0,
//           );
//         }
//       }

//       // Other connection errors
//       if (e.type == DioExceptionType.connectionError) {
//         throw ApiException(
//           message:
//               'Network connection error. Please check your internet and try again.',
//           statusCode: 0,
//         );
//       }

//       rethrow;
//     } on ApiException {
//       rethrow; // Re-throw if it's already an ApiException
//     } catch (e) {
//       // Catch any other unexpected errors
//       throw ApiException(message: 'An unexpected error occurred: $e');
//     }
//   }

//   /// Updates the user's monthly earnings
//   /// Corresponds to [POST /tools/budget/updateearnings]
//   Future<String> updateMonthlyEarnings(num monthlyEarning) async {
//     try {
//       const String path = '/tools/budget/updateearnings';

//       // Create FormData as specified in Postman
//       final formData = FormData.fromMap({
//         'MonthlyEarning': monthlyEarning.toString(),
//       });

//       final response = await _apiClient.post(path, data: formData);

//       if (response.data['success'] == true) {
//         return response.data['message'] as String;
//       } else {
//         throw ApiException(
//           message: response.data['message'] ?? 'Failed to update earnings',
//           statusCode: response.statusCode,
//         );
//       }
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw ApiException(message: 'An unexpected error occurred: $e');
//     }
//   }

//   /// Creates a new budget
//   /// Corresponds to [POST /tools/budget/create]
//   Future<String> createBudget({
//     required String budgetName,
//     required num totalBudget,
//     required num amountSpent,
//   }) async {
//     try {
//       const String path = '/tools/budget/create';

//       // Create FormData as specified in Postman
//       final formData = FormData.fromMap({
//         'TotalBudget': totalBudget.toString(),
//         'BudgetName': budgetName,
//         'amountSpent': amountSpent.toString(),
//       });

//       final response = await _apiClient.post(path, data: formData);

//       if (response.data['success'] == true) {
//         // Assuming a success message is returned, similar to updateearnings
//         return response.data['message'] ?? 'Budget created successfully';
//       } else {
//         throw ApiException(
//           message: response.data['message'] ?? 'Failed to create budget',
//           statusCode: response.statusCode,
//         );
//       }
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw ApiException(message: 'An unexpected error occurred: $e');
//     }
//   }

//   /// Updates an existing budget's target amount
//   Future<String> updateBudget({
//     required String budgetName,
//     required num newTargetAmount,
//     required num amountSpent,
//   }) async {
//     try {
//       const String path = '/tools/budget/update';

//       // **Updated FormData keys based on the provided API spec**
//       final formData = FormData.fromMap({
//         'BudgetName': budgetName,
//         'TotalBudget': newTargetAmount.toString(),
//         'amountSpent': amountSpent.toString(),
//       });

//       final response = await _apiClient.post(path, data: formData);

//       // Check for success: true in the response body
//       if (response.data['success'] == true) {
//         return response.data['message'] ?? 'Budget updated successfully';
//       } else {
//         throw ApiException(
//           message: response.data['message'] ?? 'Failed to update budget',
//           statusCode: response.statusCode,
//         );
//       }
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw ApiException(message: 'An unexpected error occurred: $e');
//     }
//   }
// }
