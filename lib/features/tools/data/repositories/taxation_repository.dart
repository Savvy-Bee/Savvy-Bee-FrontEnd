import 'dart:developer';
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/taxation.dart';

class TaxationRepository {
  final ApiClient _apiClient;

  TaxationRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<TaxationHomeResponse> getTaxationHomeData() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.taxationHome);

      if (response.data['success'] == true && response.data['data'] != null) {
        return TaxationHomeResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to load taxation data',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  Future<TaxCalculatorResponse> calculateTax({
    required int earnings,
    int? rent,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'earnings': earnings};

      // Add optional parameters if they are provided
      if (rent != null) queryParameters['rent'] = rent;

      final response = await _apiClient.get(
        ApiEndpoints.taxationCalculator,
        queryParameters: queryParameters,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        log('Tax calculation response: ${response.data}');
        return TaxCalculatorResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to calculate tax',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Upload bank statement for tax calculation
  Future<TaxCalculatorResponse> uploadBankStatement(String filePath) async {
    try {
      // Create form data with the document
      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.taxationCalculator,
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        log('Tax calculation from upload response: ${response.data}');
        return TaxCalculatorResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message:
              response.data['message'] ??
              'Failed to calculate tax from document',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  Future<TaxationStrategyResponse> getTaxationStrategies() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.taxationStrategies);

      if (response.data['success'] == true && response.data['data'] != null) {
        return TaxationStrategyResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message:
              response.data['message'] ?? 'Failed to load taxation strategies',
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

// import 'dart:developer';

// import '../../../../core/network/api_client.dart';
// import '../../../../core/network/api_endpoints.dart';
// import '../../domain/models/taxation.dart';

// class TaxationRepository {
//   final ApiClient _apiClient;

//   TaxationRepository({required ApiClient apiClient}) : _apiClient = apiClient;

//   Future<TaxationHomeResponse> getTaxationHomeData() async {
//     try {
//       final response = await _apiClient.get(ApiEndpoints.taxationHome);

//       if (response.data['success'] == true && response.data['data'] != null) {
//         return TaxationHomeResponse.fromJson(response.data);
//       } else {
//         throw ApiException(
//           message: response.data['message'] ?? 'Failed to load taxation data',
//           statusCode: response.statusCode,
//         );
//       }
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw ApiException(message: 'An unexpected error occurred: $e');
//     }
//   }

//   Future<TaxCalculatorResponse> calculateTax({
//     required int earnings,
//     int? rent,
//   }) async {
//     try {
//       final queryParameters = <String, dynamic>{'earnings': earnings};

//       // Add optional parameters if they are provided
//       if (rent != null) queryParameters['rent'] = rent;

//       final response = await _apiClient.get(
//         ApiEndpoints.taxationCalculator,
//         queryParameters: queryParameters,
//       );

//       if (response.data['success'] == true && response.data['data'] != null) {
//         log('Tax calculation response: ${response.data}');
//         return TaxCalculatorResponse.fromJson(response.data);
//       } else {
//         throw ApiException(
//           message: response.data['message'] ?? 'Failed to calculate tax',
//           statusCode: response.statusCode,
//         );
//       }
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw ApiException(message: 'An unexpected error occurred: $e');
//     }
//   }

//   Future<TaxationStrategyResponse> getTaxationStrategies() async {
//     try {
//       final response = await _apiClient.get(ApiEndpoints.taxationStrategies);

//       if (response.data['success'] == true && response.data['data'] != null) {
//         return TaxationStrategyResponse.fromJson(response.data);
//       } else {
//         throw ApiException(
//           message: response.data['message'] ?? 'Failed to load taxation strategies',
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
