import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService {
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
    }
    return '$url/api/payment';
  }

  /// 결제 준비 요청
  static Future<String> requestPaymentReady({
    required String userId,
    required String itemName,
    required String quantity,
    required int totalAmount,
  }) async {
    // 쿼리 파라미터를 Map으로 구성
    final queryParams = {
      'userId': userId,
      'itemName': itemName,
      'quantity': quantity,
      'totalAmount': '$totalAmount',
    };

    // URL 생성
    final url = Uri.parse('$baseUrl/ready')
        .replace(queryParameters: queryParams);

    print('[📦 PaymentService] 결제 준비 요청 URL: $url');

    // POST 호출 (Body 없이, 쿼리파라미터만 사용)
    final response = await http.post(url);

    print('[📦 PaymentService] 응답 코드: ${response.statusCode}');
    print('[📦 PaymentService] 응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      // 응답 Body를 JSON으로 파싱
      final body = jsonDecode(response.body);
      // PaymentReadyResponse 내에 카카오 결제 페이지로 이동할 수 있는 URL이 들어있어야 함
      // 예: nextRedirectMobileUrl, nextRedirect 등
      final redirectUrl = body['next_redirect_mobile_url'] ?? body['next_redirect_app_url'];
      if (redirectUrl == null) {
        throw Exception('응답에 결제 URL이 없습니다. (next_redirect_mobile_url / next_redirect_app_url)');
      }
      return redirectUrl;
    } else {
      throw Exception('결제 준비 실패: ${response.statusCode}');
    }
  }

  ///  결제 승인
  static Future<void> requestPaymentApprove({
    required String tid,
    required String pgToken,
    required String orderId,
    required String userId,
    required int amount,
  }) async {
    final queryParams = {
      'tid': tid,
      'pgToken': pgToken,
      'orderId': orderId,
      'userId': userId,
      'amount': '$amount',
    };

    final url = Uri.parse('$baseUrl/approve')
        .replace(queryParameters: queryParams);

    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('결제 승인 실패: ${response.statusCode}');
    }
  }
}
