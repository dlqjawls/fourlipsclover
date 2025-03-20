import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/like_status_enum.dart';

/// 리뷰 좋아요/싫어요 서비스
class ReviewLikeService {
  // .env 파일에서 API 기본 URL을 가져옵니다.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/restaurant';

  /// 더미 데이터 사용 여부 설정
  static bool useDummyData = false; // true면 더미 데이터, false면 API 요청 실행

  /// 리뷰 좋아요/싫어요 생성 또는 업데이트
  static Future<String> likeOrDislikeReview({
    required int reviewId,
    required int memberId,
    required LikeStatus likeStatus,
  }) async {
    final requestData = {
      'memberId': memberId,
      'likeStatus': likeStatus.name, // 'LIKE' 또는 'DISLIKE'
    };

    if (useDummyData) {
      // 더미 응답 데이터
      await Future.delayed(const Duration(seconds: 1));
      
      if (likeStatus == LikeStatus.LIKE) {
        return '좋아요를 했습니다';
      } else {
        return '싫어요를 했습니다';
      }
    }
    
    try {
      final url = Uri.parse('$baseUrl$apiPrefix/reviews/$reviewId/like');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['message'] ?? responseData['data'] ?? '처리되었습니다';
      } else {
        throw Exception('Failed to like/dislike review: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error liking/disliking review: $e');
    }
  }
}