import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/config/api_config.dart';

class MatchingApproveService {
  final String baseUrl = ApiConfig.baseUrl;

  // API 요청에 사용될 토큰과 userId 가져오기
  Future<Map<String, String?>> _getAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final userId = prefs.getString('userId');
    return {'token': token, 'userId': userId};
  }

  Future<Map<String, dynamic>> approveMatching({
    required String tid,
    required String pgToken,
    required String orderId,
    required String amount,
    required List<int> tagIds,
    required int regionId,
    required int guideMemberId,
    required int groupId, // groupId 파라미터 추가
    required String transportation,
    required String foodPreference,
    required String tastePreference,
    required String requirements,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final authInfo = await _getAuthInfo();
      final token = authInfo['token'];
      final userId = authInfo['userId'];

      if (token == null) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      if (userId == null) {
        throw Exception('사용자 ID가 없습니다. 로그인이 필요합니다.');
      }

      debugPrint('매칭 승인 요청 데이터:');
      debugPrint('- TID: $tid');
      debugPrint('- PG 토큰: $pgToken');
      debugPrint('- 주문 ID: $orderId');
      debugPrint('- 금액: $amount');
      debugPrint('- 사용자 ID: $userId');
      debugPrint('- 태그 ID: $tagIds');
      debugPrint('- 지역 ID: $regionId');
      debugPrint('- 가이드 ID: $guideMemberId');
      debugPrint('- 그룹 ID: $groupId');

      // API 명세에 맞는 중첩 객체 구조로 변환
      final requestBody = {
        "tags": tagIds.map((id) => {"tagId": id}).toList(),
        "region": {"regionId": regionId},
        "guide": {"memberId": guideMemberId},
        "guideRequestForm": {
          "groupId": groupId,
          "transportation": transportation,
          "foodPreference": foodPreference,
          "tastePreference": tastePreference,
          "requirements": requirements,
          "startDate": startDate,
          "endDate": endDate,
        },
      };

      // 쿼리 파라미터 구성
      final queryParams = {
        'tid': tid,
        'pgToken': pgToken,
        'orderId': orderId,
        'userId': userId,
        'amount': amount,
      };

      // URI 생성
      final uri = Uri.parse(
        '$baseUrl/api/match/approve',
      ).replace(queryParameters: queryParams);

      debugPrint('API 요청 URL: $uri');
      debugPrint('API 요청 본문: ${jsonEncode(requestBody)}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        debugPrint('매칭 승인 응답: ${response.statusCode}');
        debugPrint(
          '응답 데이터: ${response.body.substring(0, min(100, response.body.length))}...',
        );
        return data;
      } else {
        debugPrint('매칭 승인 실패: ${response.statusCode}');
        debugPrint('오류 응답: ${response.body}');
        throw Exception(
          '매칭 승인에 실패했습니다: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      debugPrint('매칭 승인 중 예외 발생: $e');
      throw Exception('매칭 승인 요청 중 오류가 발생했습니다: $e');
    }
  }
}

// 문자열 길이 제한용 함수
int min(int a, int b) {
  return a < b ? a : b;
}
