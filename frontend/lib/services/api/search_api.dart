import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/restaurant_model.dart';

class RestaurantSearchApi {
  // 베이스 URL을 .env 파일에서 가져오거나 기본값 설정
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }
  static const String apiPrefix = '/api/restaurant';

  // 식당 키워드 검색 API 호출
  static Future<List<RestaurantResponse>> searchRestaurants(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/search?query=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => RestaurantResponse.fromJson(item)).toList();
      } else {
        throw Exception('식당 검색 중 오류가 발생했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('식당 검색 중 오류가 발생했습니다: $e');
    }
  }

  // 식당 상세 정보 가져오기 (kakaoPlaceId로 조회)
  static Future<RestaurantResponse> getRestaurantDetails(String kakaoPlaceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/search'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return RestaurantResponse.fromJson(data);
      } else {
        throw Exception('식당 상세 정보를 가져오는 중 오류가 발생했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('식당 상세 정보를 가져오는 중 오류가 발생했습니다: $e');
    }
  }
}