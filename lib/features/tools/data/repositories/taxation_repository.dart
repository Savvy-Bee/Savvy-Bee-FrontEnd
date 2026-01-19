import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/taxation.dart';

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
    int? transport,
    int? feeding,
    int? utilities,
    int? others,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'earnings': earnings,
      };

      // Add optional parameters if they are provided
      if (rent != null) queryParameters['rent'] = rent;
      if (transport != null) queryParameters['transport'] = transport;
      if (feeding != null) queryParameters['feeding'] = feeding;
      if (utilities != null) queryParameters['utilities'] = utilities;
      if (others != null) queryParameters['others'] = others;

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
}