import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/payment_history.dart';
import '../auth_helper.dart';

class PaymentInitData {
  final String tid;
  final String orderId;
  final String redirectUrl;

  PaymentInitData({
    required this.tid,
    required this.orderId,
    required this.redirectUrl,
  });
}

class PaymentService {
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
    }
    return '$url/api/payment';
  }

  /// 결제 준비 요청
  static Future<PaymentInitData> requestPaymentReady({
    required String userId,
    required String itemName,
    required String quantity,
    required int totalAmount,
  }) async {
    final queryParams = {
      'userId': userId,
      'itemName': itemName,
      'quantity': quantity,
      'totalAmount': '$totalAmount',
    };

    final url = Uri.parse('$baseUrl/ready').replace(queryParameters: queryParams);

    final response = await http.post(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final redirectUrl = body['next_redirect_mobile_url'] ?? body['next_redirect_app_url'];
      final tid = body['tid'];
      final orderId = body['orderId'];

      if (redirectUrl == null || tid == null || orderId == null) {
        throw Exception('응답에 필수 값 누락');
      }

      return PaymentInitData(tid: tid, orderId: orderId, redirectUrl: redirectUrl);
    } else {
      throw Exception('결제 준비 실패: ${response.statusCode}');
    }
  }

  /// 결제 승인 요청
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

    final url = Uri.parse('$baseUrl/approve').replace(queryParameters: queryParams);
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('결제 승인 실패: ${response.statusCode}');
    }
  }

  /// 결제 취소 요청
  static Future<void> requestPaymentCancel({
    required String tid,
    required int cancelAmount,
    required int cancelTaxFreeAmount,
  }) async {
    final queryParams = {
      'cid': 'TC0ONETIME',
      'tid': tid,
      'cancelAmount': '$cancelAmount',
      'cancelTaxFreeAmount': '$cancelTaxFreeAmount',
    };

    final url = Uri.parse('$baseUrl/cancel').replace(queryParameters: queryParams);
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('결제 취소 실패: ${response.statusCode}');
    }
  }

  /// 결제 내역 조회 (GET /api/payment/{memberId})
  static Future<List<PaymentHistory>> fetchPaymentHistory({
    required String memberId,
  }) async {
    final url = Uri.parse('$baseUrl/$memberId');
    print('Fetching payment history from: $url');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json; charset=UTF-8',
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PaymentHistory.fromJson(json)).toList();
    } else {
      throw Exception('결제 내역 조회 실패: ${response.statusCode}');
    }
  }


  /// TID 기반 결제 상태 조회 API
  static Future<String?> getPaymentStatusByTid(String tid) async {
    final token = await AuthHelper.getJwtToken();

    if (token == null) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl/status/$tid');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'];
    } else {
      throw Exception('결제 상태 조회 실패: ${response.statusCode}');
    }
  }
}
