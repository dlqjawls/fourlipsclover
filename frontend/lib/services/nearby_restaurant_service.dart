import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant_models.dart';
// import '../constants/api_constants.dart';

/// 카테고리별 레스토랑 목록을 담는 클래스
class CategoryRestaurants {
  final String name; // 카테고리명
  final List<RestaurantResponse> restaurants; // 카테고리별 식당 목록

  CategoryRestaurants({required this.name, required this.restaurants});
}

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
        final restaurants =
            responseData
                .map<RestaurantResponse>(
                  (json) => RestaurantResponse.fromJson(json),
                )
                .toList();

        // 거리 계산 추가
        _calculateDistance(restaurants, latitude, longitude);

        return restaurants;
      } else {
        throw Exception(
          'Failed to get nearby restaurants: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error getting nearby restaurants: $e');
    }
  }

  /// 주변 레스토랑을 카테고리별로 그룹화하여 가져옴
  static Future<List<CategoryRestaurants>> findNearbyRestaurantsByCategory({
    required double latitude, // 실제로는 경도
    required double longitude, // 실제로는 위도
    int radius = 1000,
  }) async {
    // API 호출 시에는 그대로 전달 (백엔드가 반대로 처리하므로)
    final allRestaurants = await findNearbyRestaurants(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );

    // 거리 계산을 위해서는 원래 좌표를 전달
    _calculateDistance(allRestaurants, latitude, longitude);

    // 2. 카테고리별로 그룹화 및 정렬
    return _groupRestaurantsByCategory(allRestaurants);
  }

  /// 레스토랑에 현재 위치로부터의 거리를 계산하여 추가
  static void _calculateDistance(
    List<RestaurantResponse> restaurants,
    double apiLat, // API에 보낸 위도 값 (실제는 경도)
    double apiLng, // API에 보낸 경도 값 (실제는 위도)
  ) {
    // 실제 계산에서는 올바른 위치 값 사용
    final userLat = apiLng; // 실제 위도
    final userLng = apiLat; // 실제 경도

    for (var restaurant in restaurants) {
      if (restaurant.x != null && restaurant.y != null) {
        // x, y 값도 반대로 사용 (x가 경도, y가 위도인데 반대로 저장되어 있음)
        final restaurantLat = restaurant.y!; // 레스토랑 위도
        final restaurantLng = restaurant.x!; // 레스토랑 경도

        // 하버사인 공식을 사용한 거리 계산
        final dx = 111.3 * cos(userLat * pi / 180) * (userLng - restaurantLng);
        final dy = 111.3 * (userLat - restaurantLat);
        restaurant.distance = sqrt(dx * dx + dy * dy);
      } else {
        restaurant.distance = double.infinity;
      }
    }
  }

  /// 레스토랑을 카테고리별로 그룹화
  static List<CategoryRestaurants> _groupRestaurantsByCategory(
    List<RestaurantResponse> restaurants,
  ) {
    // 1. 카테고리별로 그룹화
    final Map<String, List<RestaurantResponse>> categoryMap = {};

    for (var restaurant in restaurants) {
      // category 필드에서 메인 카테고리 추출
      final mainCategory = _extractMainCategory(
        restaurant.category,
      ); // categoryName에서 category로 변경

      if (!categoryMap.containsKey(mainCategory)) {
        categoryMap[mainCategory] = [];
      }

      categoryMap[mainCategory]!.add(restaurant);
    }

    // 2. 각 카테고리 내에서 거리순으로 정렬
    categoryMap.forEach((category, restaurantList) {
      restaurantList.sort(
        (a, b) => (a.distance ?? double.infinity).compareTo(
          b.distance ?? double.infinity,
        ),
      );
    });

    // 3. CategoryRestaurants 리스트로 변환
    final List<CategoryRestaurants> result = [];

    categoryMap.forEach((category, restaurantList) {
      // 각 카테고리별로 상위 4개만 선택
      final topRestaurants = restaurantList.take(4).toList();

      result.add(
        CategoryRestaurants(name: category, restaurants: topRestaurants),
      );
    });

    return result;
  }

  static String _extractMainCategory(String? category) {
    if (category == null || category.isEmpty) {
      return '기타';
    }

    // "음식점 > 한식 > 육류,고기" 형태의 문자열에서 "한식" 추출
    final parts = category.split(' > ');

    if (parts.length > 1) {
      return parts[1]; // 두 번째 카테고리 반환 (한식, 일식 등)
    } else {
      return parts[0]; // 분류가 하나만 있는 경우
    }
  }
}
