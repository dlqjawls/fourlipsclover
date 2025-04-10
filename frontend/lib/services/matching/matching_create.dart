import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/config/api_config.dart';

class MatchingCreateService {
  final String baseUrl = ApiConfig.baseUrl;

  // API 요청에 사용될 토큰 가져오기
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<Map<String, dynamic>> createMatching({
    required List<int> tagIds,
    required int regionId,
    required int guideMemberId,
    required int groupId,
    required String transportation,
    required String foodPreference,
    required String tastePreference,
    required String requirements,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      debugPrint('매칭 생성 요청 데이터:');
      debugPrint('- 태그 ID: $tagIds');
      debugPrint('- 지역 ID: $regionId');
      debugPrint('- 가이드 ID: $guideMemberId');
      debugPrint('- 그룹 ID: $groupId');
      debugPrint('- 이동 수단: $transportation');
      debugPrint('- 음식 선호: $foodPreference');
      debugPrint('- 맛 선호: $tastePreference');
      debugPrint('- 요청사항: $requirements');
      debugPrint('- 시작 날짜: $startDate');
      debugPrint('- 종료 날짜: $endDate');

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

      debugPrint('API 요청 본문: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/match/create'),
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
        debugPrint('매칭 생성 응답: ${response.statusCode}');
        debugPrint(
          '응답 데이터: ${response.body.substring(0, min(100, response.body.length))}...',
        );
        return data;
      } else {
        debugPrint('매칭 생성 실패: ${response.statusCode}');
        debugPrint('오류 응답: ${response.body}');
        throw Exception(
          '매칭 생성에 실패했습니다: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      debugPrint('매칭 생성 중 예외 발생: $e');
      throw Exception('매칭 생성 요청 중 오류가 발생했습니다: $e');
    }
  }
}

// 문자열 길이 제한용 함수
int min(int a, int b) {
  return a < b ? a : b;
}
