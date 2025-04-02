import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchingCreateService {
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null) throw Exception('API_BASE_URL이 .env 파일에 정의되지 않았습니다.');
    return url;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<Map<String, dynamic>> createMatching({
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
      debugPrint('=== 매칭 생성 요청 시작 ===');

      // 요청 데이터 준비
      final requestBody = {
        "tags": tagIds.map((id) => {"tagId": id}).toList(),
        "region": {"regionId": regionId},
        "guide": {"memberId": guideMemberId},
        "guideRequestForm": {
          "transportation": transportation,
          "foodPreference": foodPreference,
          "tastePreference": tastePreference,
          "requirements": requirements,
          "startDate": startDate,
          "endDate": endDate,
        },
      };

      // 요청 데이터 디버그 출력
      debugPrint('요청 데이터: ${json.encode(requestBody)}');
      debugPrint('인증 토큰: $token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/match/create'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      // 응답 데이터 디버그 출력
      debugPrint('응답 상태 코드: ${response.statusCode}');
      final responseBody = utf8.decode(response.bodyBytes);
      debugPrint('응답 본문: $responseBody');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        debugPrint('매칭 생성 성공: $responseData');
        return responseData;
      } else {
        debugPrint('매칭 생성 실패: $responseBody');
        throw Exception('매칭 생성 실패 (${response.statusCode}): $responseBody');
      }
    } catch (e) {
      debugPrint('매칭 생성 중 오류: $e');
      throw Exception('매칭 생성 실패: $e');
    }
  }
}