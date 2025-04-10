import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../auth_helper.dart';

class MatchingApproveService {
  final String baseUrl = ApiConfig.baseUrl;

  // API 요청에 사용될 토큰 가져오기
  Future<String?> _getToken() async {
    return await AuthHelper.getJwtToken();
  }

  // API 요청에 사용될 사용자 ID 가져오기
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
    required int groupId, // groupId 파라미터 추가
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
      debugPrint('- 그룹 ID (원본): $groupId');

      // null 또는 -1로 설정해야 하는 경우 확인 (0도 null로 처리)
      final dynamic finalGroupId =
          (groupId == -1 || groupId == 0) ? null : groupId;
      debugPrint('- 그룹 ID (가공 후): $finalGroupId');

      // 요청 본문 구성 전에 guideRequestForm 객체 먼저 만들기 (모든 값을 String으로 저장)
      final Map<String, String> guideRequestForm = {
        "transportation": transportation,
        "foodPreference": foodPreference,
        "tastePreference": tastePreference,
        "requirements": requirements,
        "startDate": startDate,
        "endDate": endDate,
      };

      // groupId가 개인 사용자가 아닌 경우에만 추가 (String으로 변환)
      if (!(groupId == -1 || groupId == 0)) {
        guideRequestForm["groupId"] = "$groupId"; // 명시적으로 String으로 변환
        debugPrint('[매칭 승인] groupId를 String으로 변환하여 추가: "$groupId"');
      } else {
        debugPrint('[매칭 승인] 개인 사용자: groupId가 요청에서 제외됩니다');
      }

      // '나혼자 산다' 케이스에서는 groupId를 완전히 생략하기 위해
      // JSON 문자열을 직접 구성합니다.
      String requestBodyJson;

      if (groupId == -1 || groupId == 0) {
        // groupId가 없는 JSON 문자열 직접 구성 (id도 문자열로 변환)
        final tagsJson = jsonEncode(
          tagIds.map((id) => {"tagId": id.toString()}).toList(),
        );

        requestBodyJson = '''
        {
          "tags": $tagsJson,
          "region": {"regionId": "${regionId.toString()}"},
          "guide": {"memberId": "${guideMemberId.toString()}"},
          "guideRequestForm": {
            "transportation": "$transportation",
            "foodPreference": "$foodPreference",
            "tastePreference": "$tastePreference",
            "requirements": "$requirements",
            "startDate": "$startDate",
            "endDate": "$endDate"
          }
        }
        ''';

        debugPrint('[매칭 승인] 직접 구성한 JSON (groupId 없음): $requestBodyJson');
      } else {
        // 일반적인 케이스 - groupId가 있는 경우 (모든 숫자 값을 String으로 변환)
        final requestBodyMap = {
          "tags": tagIds.map((id) => {"tagId": id.toString()}).toList(),
          "region": {"regionId": regionId.toString()},
          "guide": {"memberId": guideMemberId.toString()},
          "guideRequestForm": {
            "groupId": groupId.toString(),
            "transportation": transportation,
            "foodPreference": foodPreference,
            "tastePreference": tastePreference,
            "requirements": requirements,
            "startDate": startDate,
            "endDate": endDate,
          },
        };

        requestBodyJson = jsonEncode(requestBodyMap);
        debugPrint('[매칭 승인] JSON 직렬화 결과 (groupId 있음): $requestBodyJson');
      }

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
      debugPrint('API 요청 본문: $requestBodyJson');
      debugPrint(
        '[매칭 승인] 최종 요청 본문 확인 (pretty): ${JsonEncoder.withIndent('  ').convert(jsonDecode(requestBodyJson))}',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBodyJson,
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
