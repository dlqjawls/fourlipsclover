import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant_models.dart';
import '../constants/api_constants.dart';

/// 주변 레스토랑 검색 서비스
class NearbyRestaurantService {
  // .env 파일에서 API 기본 URL을 가져옵니다.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  /// 주변 레스토랑 검색
  /// [latitude] 위도
  /// [longitude] 경도
  /// [radius] 검색 반경(미터), 기본값 1000
  static Future<List<RestaurantResponse>> findNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 1000,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl/api/restaurant/nearby',
      ).replace(queryParameters: queryParams);
      print('레스토랑 API 요청 URL: $uri');

      final response = await http.get(uri);
      print('API 응답 코드: ${response.statusCode}');
      print('API 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(
          utf8.decode(response.bodyBytes),
        );
        print('레스토랑 수: ${responseData.length}');
        return responseData
            .map<RestaurantResponse>(
              (json) => RestaurantResponse.fromJson(json),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to get nearby restaurants: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error getting nearby restaurants: $e');
    }
  }
}
