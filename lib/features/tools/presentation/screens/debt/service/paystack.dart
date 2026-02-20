import 'dart:convert';
import 'package:http/http.dart' as http;

class PaystackService {
  static const _baseUrl = 'https://api.paystack.co';

  final String secretKey;

  PaystackService(this.secretKey);

  Future<List<Map<String, String>>> fetchBanks() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/bank?currency=NGN'),
      headers: {'Authorization': 'Bearer $secretKey'},
    );

    final body = jsonDecode(res.body);
    final List data = body['data'];

    return data
        .map<Map<String, String>>(
          (e) => {
            'name': e['name'],
            'code': e['code'],
          },
        )
        .toList();
  }

  Future<String> resolveAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    final res = await http.get(
      Uri.parse(
        '$_baseUrl/bank/resolve?account_number=$accountNumber&bank_code=$bankCode',
      ),
      headers: {'Authorization': 'Bearer $secretKey'},
    );

    final body = jsonDecode(res.body);

    if (body['status'] != true) {
      throw Exception(body['message']);
    }

    return body['data']['account_name'];
  }
}