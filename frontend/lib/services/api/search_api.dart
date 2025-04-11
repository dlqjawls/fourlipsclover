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

  // 식당 키워드 검색 API 호출 (태그 ID, 위치 검색 지원 추가)
  static Future<List<RestaurantResponse>> searchRestaurants(
    String query, {
    List<int>? tagIds, // 태그 ID 목록 매개변수
    double? latitude,
    double? longitude,
  }) async {
    try {
      // 쿼리 파라미터 구성
      final queryParams = <String, String>{
        'query': query, // 빈 문자열이라도 항상 포함 (백엔드 요구사항)
      };

      // 태그 ID가 있으면 추가 (Long 타입의 리스트로 전송)
      if (tagIds != null && tagIds.isNotEmpty) {
        // tagIds=[1,2,3] 형태로 전송
        queryParams['tagIds'] = tagIds.join(',');
      }

      // URL 구성
      final uri = Uri.parse(
        '$baseUrl$apiPrefix/search',
      ).replace(queryParameters: queryParams);
      print('레스토랑 검색 API 요청 URL: $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
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
  static Future<RestaurantResponse> getRestaurantDetails(
    String kakaoPlaceId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/search'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return RestaurantResponse.fromJson(data);
      } else {
        throw Exception(
          '식당 상세 정보를 가져오는 중 오류가 발생했습니다. 상태 코드: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('식당 상세 정보를 가져오는 중 오류가 발생했습니다: $e');
    }
  }
}
