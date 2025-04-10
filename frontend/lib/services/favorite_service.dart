import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class FavoriteService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/restaurant';

  /// 즐겨찾기 추가 (restaurantId 기반)
  static Future<bool> addFavorite(int restaurantId, int memberId) async {
    final url = Uri.parse('$baseUrl$apiPrefix/$restaurantId/favorite?memberId=$memberId');
    final response = await http.post(
      url,
      headers: {'accept': '*/*'},
    );
    print('❤️ 즐겨찾기 요청 응답: ${response.statusCode}');
    return response.statusCode == 200;
  }

  /// 즐겨찾기 조회 (restaurantId 목록 반환)
  static Future<List<int>> getFavoriteRestaurantIds(int memberId) async {
    final url = Uri.parse('$baseUrl$apiPrefix/$memberId/favorite');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .where((item) => item['restaurant'] != null)
          .map<int>((item) => item['restaurant']['restaurantId'] as int)
          .toList();
    } else {
      print('💔 즐겨찾기 조회 실패: ${response.statusCode}');
      return [];
    }
  }

  static Future<bool> removeFavorite({
    required int restaurantId,
    required int memberId,
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl$apiPrefix/$restaurantId/favorite/$memberId');

    final response = await http.delete(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('💔 즐겨찾기 삭제 응답: ${response.statusCode}');
    return response.statusCode == 204;
  }

}
