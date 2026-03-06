// lib/features/tools/data/repositories/filing_home_repository.dart
// No changes needed to this file — re-emitted for completeness.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';

class FilingHomeRepository {
  static const _baseUrl = ApiEndpoints.baseUrl;

  final String bearerToken;
  const FilingHomeRepository({required this.bearerToken});

  Future<FilingHomeData> fetchHomeData() async {
    final uri =
        Uri.parse('$_baseUrl/tools/taxation/filling/fetchdata/home');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    print('FilingHomeRepository: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch filing home data: ${response.statusCode} ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception('API returned success=false: ${body['message']}');
    }

    return FilingHomeData.fromJson(body['data'] as Map<String, dynamic>);
  }
}


// // lib/features/tools/data/repositories/filing_home_repository.dart

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';

// class FilingHomeRepository {
//   static const _baseUrl = ApiEndpoints.baseUrl;

//   final String bearerToken;

//   const FilingHomeRepository({required this.bearerToken});

//   Future<FilingHomeData> fetchHomeData() async {
//     final uri = Uri.parse('$_baseUrl/tools/taxation/filling/fetchdata/home');

//     final response = await http.get(
//       uri,
//       headers: {
//         'Authorization': 'Bearer $bearerToken',
//         'Content-Type': 'application/json',
//       },
//     );

//     print('FilingHomeRepository: Received response with status ${response.statusCode} and body: ${response.body}');

//     if (response.statusCode != 200) {
//       throw Exception(
//         'Failed to fetch filing home data: ${response.statusCode} ${response.body}',
//       );
//     }

//     final body = jsonDecode(response.body) as Map<String, dynamic>;

//     if (body['success'] != true) {
//       throw Exception('API returned success=false: ${body['message']}');
//     }

//     return FilingHomeData.fromJson(body['data'] as Map<String, dynamic>);
//   }
// }
