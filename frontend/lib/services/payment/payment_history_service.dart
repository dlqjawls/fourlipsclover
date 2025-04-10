import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_payment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_helper.dart';

class PaymentService {
  // JWT 토큰 직접 사용 대신 헬퍼 통해 가져오기
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  PaymentService();

  // 인증 토큰 가져오기
  Future<String?> _getToken() async {
    return await AuthHelper.getJwtToken();
  }

  /// ✅ 결제 내역 조회 API
  Future<List<Payment>> getPaymentHistory() async {
    print("결제 내역 데이터 요청");

    // 🔄 API 연결 여부를 설정하는 플래그
    bool useDummyData = true; // true면 더미 데이터, false면 API 요청 실행

    if (useDummyData) {
      // ✅ 더미 데이터 버전 시작
      await Future.delayed(const Duration(seconds: 1)); // 가짜 네트워크 지연

      return [
        Payment(
          id: '1',
          amount: 15000,
          date: DateTime.now().subtract(const Duration(days: 1)),
          description: '김쿨라멘 - 라멘 2개, 돈카츠 1개',
        ),
        Payment(
          id: '2',
          amount: 8000,
          date: DateTime.now().subtract(const Duration(days: 3)),
          description: '김쿨라멘 - 라멘 1개',
        ),
        Payment(
          id: '3',
          amount: 12000,
          date: DateTime.now().subtract(const Duration(days: 7)),
          description: '김쿨라멘 - 덮밥 2개',
        ),
        Payment(
          id: '4',
          amount: 25000,
          date: DateTime.now().subtract(const Duration(days: 14)),
          description: '김쿨라멘 - 라멘 2개, 돈카츠 1개, 덮밥 1개',
        ),
        Payment(
          id: '5',
          amount: 10000,
          date: DateTime.now().subtract(const Duration(days: 20)),
          description: '김쿨라멘 - 돈카츠 1개, 음료 2개',
        ),
      ];
      // ✅ 더미 데이터 버전 끝
    }
    // 🔄 API 요청 실행
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/payments/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map<Payment>((json) => Payment.fromJson(json)).toList();
      } else {
        print("❌ 서버 오류: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ API 요청 중 오류 발생: $e");
      return [];
    }
  }

  /// ✅ 결제 상세 내역 조회 API
  Future<Payment?> getPaymentDetail(String paymentId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/payments/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return Payment.fromJson(data);
      } else {
        print("❌ 서버 오류: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ API 요청 중 오류 발생: $e");
      return null;
    }
  }
}
