import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/config/api_config.dart';
class MatchingApproveService {
  final String baseUrl = ApiConfig.baseUrl;
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<Map<String, dynamic>> approveMatching({
    required String tid,
    required String pgToken,
    required String orderId,
    required String amount,
    required List<int> tagIds,
    required int regionId,
    required int guideMemberId,
    required String transportation,
    required String foodPreference,
    required String tastePreference,
    required String requirements,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      if (userId == null) {
        throw Exception('사용자 ID를 찾을 수 없습니다.');
      }

      debugPrint('=== 매칭 승인 요청 시작 ===');

      final queryParams = {
        'tid': tid,
        'pgToken': pgToken,
        'orderId': orderId,
        'userId': userId,
        'amount': amount.toString(),
      };

      final requestBody = {
        "tags": tagIds.map((id) => {"tagId": id}).toList(),
        "region": {"regionId": regionId},
        "guide": {"memberId": guideMemberId},
        "guideRequestForm": {
          // "guideRequestFormId": 5,
          "transportation": transportation,
          "foodPreference": foodPreference,
          "tastePreference": tastePreference,
          "requirements": requirements,
          "startDate": startDate,
          "endDate": endDate,
        },
      };

      final uri = Uri.parse(
        '$baseUrl/api/match/approve',
      ).replace(queryParameters: queryParams);

      debugPrint('요청 URL: $uri');
      debugPrint('요청 본문: $requestBody');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      debugPrint('응답 상태 코드: ${response.statusCode}');
      final responseBody = utf8.decode(response.bodyBytes);
      debugPrint('응답 본문: $responseBody');

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('매칭 승인 실패 (${response.statusCode}): $responseBody');
      }
    } catch (e) {
      debugPrint('매칭 승인 중 오류: $e');
      throw Exception('매칭 승인 실패: $e');
    }
  }
}
