import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant_models.dart';
import '../constants/api_constants.dart';

class RestaurantService {
  // .env 파일에서 API 기본 URL을 가져옵니다.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/restaurant';

  /// 더미 데이터 사용 여부 설정
  static bool useDummyData = false; // true면 더미 데이터, false면 API 요청 실행

  /// ✅ 가게 상세 정보 가져오기 (API 연동)
  static Future<Map<String, dynamic>> fetchRestaurantDetails(String restaurantId) async {
    print("Fetching restaurant details for restaurantId: $restaurantId");

    if (useDummyData) {
      // ✅ 더미 데이터 버전 (백엔드 연동 전)
      await Future.delayed(const Duration(seconds: 1)); // 가짜 네트워크 지연

      return {
        'id': restaurantId,
        'name': '김쿨라멘',
        'image': 'https://source.unsplash.com/400x300/?ramen',
        'menu': ['라멘', '돈카츠', '덮밥'],
        'address': '서울특별시 강남구 테헤란로 10길 9',
        'phone': '02-1234-5678',
        'business_hours': '11:00 - 22:00',
        'tags': ['#혼밥', '#일식', '#가성비맛집', '#매운맛'],
      };
    }

    // 실제 API 연동 버전
    try {
      final response = await http.get(
          Uri.parse('$baseUrl$apiPrefix/$restaurantId/search')
      );

      if (response.statusCode == 200) {
        final utf8Decoded = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(utf8Decoded);

        // ✅ menu가 없으면 기본값 추가
        if (!jsonData.containsKey('menu') || jsonData['menu'] == null) {
          jsonData['menu'] = ["설렁탕", "순대국밥"]; // ✅ 기본 메뉴 설정
        }

        print("JSON 데이터 확인: $jsonData");
        return jsonData;
      } else {
        print("Error: 서버 응답 코드 ${response.statusCode}");
        throw Exception('Failed to get restaurant: ${response.statusCode}');
      }
    } catch (e) {
      print("API 요청 중 오류 발생: $e");
      throw Exception('Error getting restaurant: $e');
    }
  }

  /// 카카오 장소 ID로 레스토랑 정보 조회
  static Future<RestaurantResponse> getRestaurantByKakaoId(String kakaoPlaceId) async {
    if (useDummyData) {
      // 더미 데이터 반환
      await Future.delayed(const Duration(seconds: 1));

      return RestaurantResponse(
        restaurantId: 1,
        kakaoPlaceId: kakaoPlaceId,
        placeName: '김쿨라멘 강남점',
        addressName: '서울특별시 강남구 테헤란로 10길 9',
        roadAddressName: '서울특별시 강남구 테헤란로 10길 9',
        category: 'FD6',
        categoryName: '음식점 > 일식 > 라멘',
        phone: '02-1234-5678',
        placeUrl: 'https://place.map.kakao.com/12345',
        x: 127.0415,
        y: 37.5011,
      );
    }

    try {
      final url = Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/search');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return RestaurantResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get restaurant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting restaurant: $e');
    }
  }
}