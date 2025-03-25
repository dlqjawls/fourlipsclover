import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService {
  /// .env에서 API 주소를 불러옵니다.
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
    }
    return '$url/payment';
  }

  /// 결제 준비 요청
  static Future<String> requestPaymentReady({
    required int amount,
    required String itemName,
    required int memberId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ready'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'item_name': itemName,
        'memberId': memberId,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (!body.containsKey('next_redirect_mobile_url')) {
        throw Exception('응답에 결제 URL이 없습니다.');
      }

      return body['next_redirect_mobile_url'];
    } else {
      throw Exception('결제 준비 실패: ${response.statusCode}');
    }
  }

  /// 결제 승인 요청
  static Future<void> requestPaymentApprove({
    required String pgToken,
    required int memberId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/approve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pg_token': pgToken,
        'memberId': memberId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('결제 승인 실패: ${response.statusCode}');
    }
  }
}
