import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';


class UserService {
  final UserProvider userProvider;
  final _secureStorage = const FlutterSecureStorage();

  UserService({required this.userProvider});

  Future<UserProfile> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await _secureStorage.read(key: 'jwt_token');
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
      final token = await _secureStorage.read(key: 'jwt_token');
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
      final token = await _secureStorage.read(key: 'jwt_token');
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

  Future<Map<String, dynamic>> getCategoryAnalysis() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      debugPrint('=== 카테고리 분석 조회 시작 ===');

      final token = await _secureStorage.read(key: 'jwt_token');

      final baseUrl = dotenv.env['API_BASE_URL'];

      debugPrint('API_BASE_URL: $baseUrl');
      debugPrint('JWT 토큰 존재 여부: ${token != null}');

      if (baseUrl == null) {
        throw Exception('API_BASE_URL이 설정되지 않았습니다.');
      }

      if (token == null) {
        throw Exception('JWT 토큰이 없습니다. 다시 로그인해주세요.');
      }

      final url = Uri.parse('$baseUrl/api/spending-analysis/category');
      debugPrint('요청 URL: $url');

      try {
        // Postman과 동일하게 Bearer 토큰 형식 사용
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $token',
          },
        );

        debugPrint('=== 서버 응답 ===');
        debugPrint('상태 코드: ${response.statusCode}');
        debugPrint('응답 헤더: ${response.headers}');
        debugPrint('응답 본문: ${response.body}');

        if (response.statusCode == 200) {
          try {
            final data = utf8.decode(response.bodyBytes);
            debugPrint('디코딩된 응답 데이터: $data');

            final jsonResponse = json.decode(data);
            debugPrint('JSON 파싱 결과: $jsonResponse');

            // Postman 응답 형식에 맞게 처리
            if (jsonResponse['categorySpending'] == null) {
              debugPrint('경고: categorySpending이 없습니다. 전체 응답: $jsonResponse');
              return _getExampleData();
            }

            // categorySpending 객체를 categories와 amounts 배열로 변환
            final Map<String, dynamic> categorySpending =
                jsonResponse['categorySpending'] as Map<String, dynamic>;
            debugPrint('categorySpending: $categorySpending');

            final List<String> categories = [];
            final List<int> amounts = [];

            categorySpending.forEach((category, amount) {
              debugPrint(
                '카테고리: $category, 금액: $amount (${amount.runtimeType})',
              );
              categories.add(category);
              // 숫자가 문자열로 들어올 수 있으므로 파싱 처리
              amounts.add(
                amount is int ? amount : int.parse(amount.toString()),
              );
            });

            debugPrint('변환된 categories: $categories');
            debugPrint('변환된 amounts: $amounts');

            // 앱에서 예상하는 형식으로 변환된 데이터 반환
            final result = {
              'categories': categories,
              'amounts': amounts,
              'totalVisits': jsonResponse['totalVisits'],
              'totalAmount': jsonResponse['totalAmount'],
            };

            debugPrint('=== 변환 완료된 결과 데이터 ===');
            debugPrint('$result');

            return result;
          } catch (e) {
            debugPrint('=== 응답 데이터 처리 중 오류 발생 ===');
            debugPrint('오류 유형: ${e.runtimeType}');
            debugPrint('오류 메시지: $e');
            return _getExampleData();
          }
        } else {
          debugPrint('HTTP 오류 상태 코드: ${response.statusCode}');
          return _getExampleData();
        }
      } catch (e) {
        debugPrint('=== HTTP 요청 자체 실패 ===');
        debugPrint('오류 유형: ${e.runtimeType}');
        debugPrint('오류 메시지: $e');
        return _getExampleData();
      }
    } catch (e) {
      debugPrint('=== getCategoryAnalysis 전체 실패 ===');
      debugPrint('오류 유형: ${e.runtimeType}');
      debugPrint('오류 메시지: $e');
      return _getExampleData();
    }
  }

  // 예시 데이터 반환 메서드
  Map<String, dynamic> _getExampleData() {
    debugPrint('=== 예시 데이터 사용 ===');
    return {
      'categories': ['양식', '일식', '한식', '디저트', '분식'],
      'amounts': [80000, 50000, 70000, 90000, 60000],
      'totalVisits': 15,
      'totalAmount': 350000,
    };
  }
}
