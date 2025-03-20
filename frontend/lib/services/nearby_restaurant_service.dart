import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant_models.dart';
import '../constants/api_constants.dart';

/// 주변 레스토랑 검색 서비스
class NearbyRestaurantService {
  // .env 파일에서 API 기본 URL을 가져옵니다.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/restaurant';

  /// 더미 데이터 사용 여부 설정
  static bool useDummyData = false; // true면 더미 데이터, false면 API 요청 실행

  /// 주변 레스토랑 검색
  /// [latitude] 위도
  /// [longitude] 경도
  /// [radius] 검색 반경(미터), 기본값 1000
  static Future<List<RestaurantResponse>> findNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 1000,
  }) async {
    if (useDummyData) {
      // 더미 데이터 반환
      await Future.delayed(const Duration(seconds: 1));

      return [
        RestaurantResponse(
          restaurantId: 1,
          kakaoPlaceId: 'dummy_place_id_1',
          placeName: '김쿨라멘 강남점',
          addressName: '서울특별시 강남구 테헤란로 10길 9',
          roadAddressName: '서울특별시 강남구 테헤란로 10길 9',
          category: 'FD6',
          categoryName: '음식점 > 일식 > 라멘',
          phone: '02-1234-5678',
          placeUrl: 'https://place.map.kakao.com/12345',
          x: 127.0415,
          y: 37.5011,
        ),
        RestaurantResponse(
          restaurantId: 2,
          kakaoPlaceId: 'dummy_place_id_2',
          placeName: '스시코우지',
          addressName: '서울특별시 강남구 테헤란로 8길 22',
          roadAddressName: '서울특별시 강남구 테헤란로 8길 22',
          category: 'FD6',
          categoryName: '음식점 > 일식 > 초밥,롤',
          phone: '02-555-6789',
          placeUrl: 'https://place.map.kakao.com/67890',
          x: 127.0402,
          y: 37.5018,
        ),
      ];
    }

    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl$apiPrefix/nearby',
      ).replace(queryParameters: queryParams);
      print('레스토랑 API 요청 URL: $uri');

      final response = await http.get(uri);
      print('API 응답 코드: ${response.statusCode}');
      print('API 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
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
