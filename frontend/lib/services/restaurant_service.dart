import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant_model.dart';

class RestaurantService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/restaurant';

  /// ✅ 가게 상세 정보 가져오기 (실제 API 연동)
  static Future<Map<String, dynamic>> fetchRestaurantDetails(String restaurantId) async {
    print("Fetching restaurant details for restaurantId: $restaurantId");

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/$restaurantId/search'),
      );

      if (response.statusCode == 200) {
        final utf8Decoded = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(utf8Decoded);

        // ✅ menu가 없으면 기본값 추가
        if (!jsonData.containsKey('menu') || jsonData['menu'] == null) {
          jsonData['menu'] = ["설렁탕", "순대국밥"]; // 기본 메뉴 설정
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

  /// ✅ 카카오 장소 ID로 레스토랑 정보 조회
  static Future<RestaurantResponse> getRestaurantByKakaoId(String kakaoPlaceId) async {
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
