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

      debugPrint('=== 사용자 프로필 조회 시작 ===');
      debugPrint('API_BASE_URL: $baseUrl');
      debugPrint('userId: $userIdStr');
      debugPrint('JWT 토큰 존재 여부: ${token != null}');

      if (userIdStr == null) {
        throw Exception('사용자 ID를 찾을 수 없습니다.');
      }

      if (baseUrl == null) {
        throw Exception('API_BASE_URL이 설정되지 않았습니다.');
      }

      if (token == null) {
        throw Exception('JWT 토큰이 없습니다. 다시 로그인해주세요.');
      }

      final url = Uri.parse('$baseUrl/api/mypage/$userIdStr');
      debugPrint('요청 URL: $url');

      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': token,
          },
        );

        debugPrint('=== 서버 응답 ===');
        debugPrint('상태 코드: ${response.statusCode}');
        debugPrint('응답 헤더: ${response.headers}');
        debugPrint('응답 본문: ${response.body}');

        if (response.statusCode == 200) {
          final data = utf8.decode(response.bodyBytes);
          final jsonData = json.decode(data);

          try {
            final userProfile = UserProfile.fromJson(jsonData);
            userProvider.setUserProfile(userProfile);
            debugPrint('=== 프로필 변환 성공 ===');
            debugPrint('프로필 데이터: ${userProfile.toJson()}');
            return userProfile;
          } catch (e) {
            debugPrint('=== 프로필 변환 실패 ===');
            debugPrint('오류: $e');
            debugPrint('원본 데이터: $jsonData');
            throw Exception('사용자 프로필 데이터 형식이 올바르지 않습니다.');
          }
        } else if (response.statusCode == 401) {
          throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
        } else if (response.statusCode == 404) {
          throw Exception('사용자 정보를 찾을 수 없습니다.');
        } else if (response.statusCode == 500) {
          // 서버 오류 시 상세 정보 로깅
          try {
            final errorData = json.decode(response.body);
            debugPrint('=== 서버 오류 상세 ===');
            debugPrint('에러 메시지: ${errorData['message'] ?? errorData['error']}');
            debugPrint('경로: ${errorData['path']}');
          } catch (e) {
            debugPrint('서버 오류 응답 파싱 실패: $e');
          }
          throw Exception('서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
        } else {
          throw Exception('서버 응답 오류: ${response.statusCode}\n${response.body}');
        }
      } catch (e) {
        debugPrint('=== API 호출 실패 ===');
        debugPrint('오류: $e');
        rethrow;
      }
    } catch (e) {
      debugPrint('=== getUserProfile 전체 실패 ===');
      debugPrint('오류: $e');
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
