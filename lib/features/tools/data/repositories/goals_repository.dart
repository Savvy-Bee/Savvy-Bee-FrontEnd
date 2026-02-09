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
    } on DioException catch (e) {
      // ✅ CRITICAL FIX: Handle connection error but parse data if available
      if (e.type == DioExceptionType.connectionError &&
          e.response?.data != null &&
          e.response?.data['success'] == true) {
        print('⚠️ Connection error but data received - parsing anyway');

        try {
          final responseData = e.response!.data as Map<String, dynamic>;
          final dataList = responseData['data'] as List;

          final goals = dataList
              .map((json) => SavingsGoal.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse(
            success: responseData['success'] as bool,
            message: responseData['message'] as String,
            data: goals,
          );
        } catch (parseError) {
          print('❌ Failed to parse data from error response: $parseError');
          throw ApiException(
            message: 'Network error: Connection reset while reading response',
            statusCode: 0,
          );
        }
      }

      // Other connection errors
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
      print('❌ Unexpected error in getHomeData: $e');
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

      print('📤 Sending create savings request:');
      print('  - Name: $name');
      print('  - TotalSavings: $totalSavings');
      print('  - Amountsaved: $amountSaved');
      print('  - enddate: $endDate');

      final response = await apiClient.post(
        '/tools/savings/create',
        data: formData,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // ✅ FIX: The API returns data as an object, not a list
        // Check if data is a Map (single object) or List
        final data = responseData['data'];
        SavingsGoal goal;

        if (data is List) {
          // If it's a list, take the first item
          goal = SavingsGoal.fromJson(data.first as Map<String, dynamic>);
        } else if (data is Map<String, dynamic>) {
          // If it's a single object, parse it directly
          goal = SavingsGoal.fromJson(data);
        } else {
          throw ApiException(
            message: 'Unexpected data format in response',
            statusCode: response.statusCode,
          );
        }

        print('✅ Goal created successfully: ${goal.goalName}');

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
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Response: ${e.response?.data}');

      // Handle connection errors
      if (e.type == DioExceptionType.connectionError &&
          e.response?.data != null &&
          e.response?.data['success'] == true) {
        try {
          final responseData = e.response!.data as Map<String, dynamic>;

          // ✅ FIX: Handle both formats here too
          final data = responseData['data'];
          SavingsGoal goal;

          if (data is List) {
            goal = SavingsGoal.fromJson(data.first as Map<String, dynamic>);
          } else if (data is Map<String, dynamic>) {
            goal = SavingsGoal.fromJson(data);
          } else {
            throw ApiException(
              message: 'Unexpected data format in error response',
              statusCode: 0,
            );
          }

          print(
            '✅ Goal created successfully (from error response): ${goal.goalName}',
          );

          return ApiResponse(
            success: responseData['success'] as bool,
            message: responseData['message'] as String,
            data: goal,
          );
        } catch (parseError) {
          print('❌ Parse error: $parseError');
          throw ApiException(
            message: 'Network error: Connection reset while reading response',
            statusCode: 0,
          );
        }
      }

      if (e.type == DioExceptionType.connectionError) {
        throw ApiException(
          message: 'Network connection error. Please try again.',
          statusCode: 0,
        );
      }

      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError &&
          e.response?.data != null &&
          e.response?.data['success'] == true) {
        try {
          final responseData = e.response!.data as Map<String, dynamic>;
          final goal = SavingsGoal.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );

          return ApiResponse(
            success: responseData['success'] as bool,
            message: responseData['message'] as String,
            data: goal,
          );
        } catch (parseError) {
          throw ApiException(
            message: 'Network error: Connection reset while reading response',
            statusCode: 0,
          );
        }
      }

      rethrow;
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError &&
          e.response?.data != null &&
          e.response?.data['success'] == true) {
        try {
          final responseData = e.response!.data as Map<String, dynamic>;
          final goal = SavingsGoal.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );

          return ApiResponse(
            success: responseData['success'] as bool,
            message: responseData['message'] as String,
            data: goal,
          );
        } catch (parseError) {
          throw ApiException(
            message: 'Network error: Connection reset while reading response',
            statusCode: 0,
          );
        }
      }

      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to withdraw funds from savings: $e');
    }
  }
}
