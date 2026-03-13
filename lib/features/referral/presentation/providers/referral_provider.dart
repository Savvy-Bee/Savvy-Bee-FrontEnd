import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/referral/domain/models/referral_model.dart';

final referralProvider = FutureProvider<ReferralData>((ref) async {
  final token = ref.watch(authRepositoryProvider).getAuthToken();
  final url = ApiEndpoints.baseUrl;
  final response = await http.get(
    Uri.parse(
      '$url/auth/profile/referral/dashboard',
    ),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['success'] == true) {
      return ReferralData.fromJson(json);
    }
    throw Exception(json['message'] ?? 'Failed to fetch referral data');
  } else {
    throw Exception('Failed to fetch referral data: ${response.statusCode}');
  }
});