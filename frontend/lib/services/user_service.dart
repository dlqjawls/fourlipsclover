import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final UserProvider userProvider;

  UserService({required this.userProvider});

  Future<UserProfile> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      final baseUrl = dotenv.env['API_BASE_URL'];
      final userIdStr = prefs.getString('userId');

      debugPrint('토큰: $token'); // 디버깅
      debugPrint('userId 문자열: $userIdStr'); // 디버깅

      if (userIdStr == null) {
        throw Exception('사용자 ID를 찾을 수 없습니다.');
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/mypage/dummy?memberId=$userIdStr',
        ), // int 변환 없이 문자열 그대로 사용
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': '$token',
        },
      );

      debugPrint('응답 상태 코드: ${response.statusCode}'); // 디버깅

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(data);
        debugPrint('응답 데이터: $jsonData'); // 디버깅

        final userProfile = UserProfile.fromJson(jsonData);
        userProvider.setUserProfile(userProfile);
        return userProfile;
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('getUserProfile 에러: $e');
      rethrow;
    }
  }

  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      final baseUrl = dotenv.env['API_BASE_URL'];

      final url = Uri.parse('$baseUrl/api/mypage/$userId/upload-profile-image');

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = '$token';
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return decodedResponse['profileImageUrl'];
      } else {
        throw Exception('이미지 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('uploadProfileImage 에러: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSpendingHistory({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      final baseUrl = dotenv.env['API_BASE_URL'];

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/spending-analysis/history?startDate=$startDate&endDate=$endDate',
        ),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        return json.decode(data);
      } else {
        throw Exception('소비 내역 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('getSpendingHistory 에러: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCategoryAnalysis({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      final baseUrl = dotenv.env['API_BASE_URL'];

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/spending-analysis/category?startDate=$startDate&endDate=$endDate',
        ),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        return json.decode(data);
      } else {
        throw Exception('카테고리 분석 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('getCategoryAnalysis 에러: $e');
      rethrow;
    }
  }
}
