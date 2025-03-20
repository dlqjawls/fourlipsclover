import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 레스토랑 API 클래스
/// 백엔드 서버와의 HTTP 통신을 담당합니다.
class RestaurantApi {
  // .env 파일에서 API 기본 URL을 가져옵니다.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/restaurant';
  
  /// 카카오 장소 ID로 레스토랑 정보 조회
  /// [kakaoPlaceId] 카카오 장소 ID
  static Future<Map<String, dynamic>> getRestaurantByKakaoId(String kakaoPlaceId) async {
    final url = Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/search');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get restaurant: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting restaurant: $e');
    }
  }
  
  /// 리뷰 작성
  /// [reviewData] 리뷰 생성 요청 데이터
  static Future<Map<String, dynamic>> createReview(Map<String, dynamic> reviewData) async {
    final url = Uri.parse('$baseUrl$apiPrefix/reviews');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reviewData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create review: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }
  
  /// 특정 리뷰 상세 조회
  /// [kakaoPlaceId] 카카오 장소 ID
  /// [reviewId] 리뷰 ID
  static Future<Map<String, dynamic>> getReviewDetail(String kakaoPlaceId, int reviewId) async {
    final url = Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/reviews/$reviewId');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get review detail: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting review detail: $e');
    }
  }
  
  /// 특정 장소의 모든 리뷰 목록 조회
  /// [kakaoPlaceId] 카카오 장소 ID
  static Future<List<dynamic>> getReviewList(String kakaoPlaceId) async {
    final url = Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/reviews');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get review list: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting review list: $e');
    }
  }
  
  /// 리뷰 수정
  /// [reviewId] 리뷰 ID
  /// [reviewData] 리뷰 수정 요청 데이터
  static Future<Map<String, dynamic>> updateReview(int reviewId, Map<String, dynamic> reviewData) async {
    final url = Uri.parse('$baseUrl$apiPrefix/reviews/$reviewId');
    
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reviewData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update review: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating review: $e');
    }
  }
  
  /// 리뷰 삭제
  /// [reviewId] 리뷰 ID
  static Future<Map<String, dynamic>> deleteReview(int reviewId) async {
    final url = Uri.parse('$baseUrl$apiPrefix/reviews/$reviewId');
    
    try {
      final response = await http.delete(url);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete review: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }
}