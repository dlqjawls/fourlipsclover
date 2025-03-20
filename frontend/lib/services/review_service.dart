import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant_models.dart';
import '../models/review_model.dart';
import '../constants/api_constants.dart';

class ReviewService {
  // .env 파일에서 API 기본 URL을 가져옵니다.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/restaurant';

  /// 더미 데이터 사용 여부 설정
  static bool useDummyData = false; // true면 더미 데이터, false면 API 요청 실행

  /// ✅ 리뷰 목록 조회 API (기존 방식)
  static Future<List<Review>> fetchReviews(String restaurantId) async {
    print("리뷰 데이터 요청: restaurantId = $restaurantId");

    if (useDummyData) {
      // 더미 데이터 버전 시작
      await Future.delayed(const Duration(seconds: 1)); // 가짜 네트워크 지연

      return [
        Review(
            id: '1',
            restaurantId: restaurantId,
            userId: 'user123',
            username: '사용자1',
            title: '훌륭한 경험!',
            content: '이 식당 최고예요! 음식도 맛있고 분위기도 너무 좋아요. '
                '특히 라멘과 돈카츠가 정말 훌륭했어요. 면발이 쫄깃하고 육수가 깊은 맛을 내더라고요. '
                '직원들도 친절하고 서비스가 빨라서 기분 좋게 식사를 했어요. '
                '다음에 또 방문할 생각입니다. 적극 추천해요!',
            likes: 45,
            dislikes: 2,
            visitCount: 5,
            imageUrl: null,
            isLocal: true,
            localRank: 1,
            date: DateTime.now(),
            menu: ['라멘', '돈카츠']
        ),
        Review(
            id: '2',
            restaurantId: restaurantId,
            userId: 'user456',
            username: '사용자2',
            title: '별로였어요...',
            content: '조금 별로였어요... 기대했던 맛이 아니었어요. '
                '음식이 생각보다 차갑고, 조리가 덜 된 느낌이었어요. '
                '직원들의 응대도 다소 불친절했고, 주문이 늦게 나왔어요. '
                '가격 대비 만족도가 낮아서 다시 방문하지 않을 것 같아요.',
            likes: 4,
            dislikes: 10,
            visitCount: 1,
            imageUrl: null,
            isLocal: false,
            localRank: 3,
            date: DateTime.now().subtract(Duration(days: 3)),
            menu: ['덮밥']
        ),
        // ... 다른 더미 리뷰들
      ];
    }

    // API 요청 실행
    try {
      final url = Uri.parse('$baseUrl$apiPrefix/$restaurantId/reviews');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        return data.map<Review>((review) {
          return Review(
            id: review['id'],
            restaurantId: review['restaurant_id'],
            userId: review['user_id'],
            username: review['username'],
            title: review['title'] ?? '리뷰',
            content: review['content'],
            likes: review['likes'],
            dislikes: review['dislikes'],
            visitCount: review['visit_count'],
            imageUrl: review['image_url'],
            isLocal: review['is_local'],
            localRank: review['local_rank'],
            date: DateTime.parse(review['date']),
            menu: (review['menu'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          );
        }).toList();
      } else {
        print("❌ 서버 오류: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ API 요청 중 오류 발생: $e");
      return [];
    }
  }

  /// 특정 장소의 모든 리뷰 목록 조회 (백엔드 API 방식)
  static Future<List<ReviewResponse>> getReviewList(String kakaoPlaceId) async {
    if (useDummyData) {
      // 더미 리뷰 데이터 반환
      await Future.delayed(const Duration(seconds: 1));
      
      return [
        ReviewResponse(
          reviewId: 1,
          content: '맛있어요! 라멘이 정말 깔끔하고 육수가 진한 편이에요.',
          reviewer: ReviewMemberResponse(
            memberId: 101,
            nickname: '라멘러버',
            email: 'ramen@example.com',
          ),
          visitedAt: DateTime.now().subtract(const Duration(days: 3)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ReviewResponse(
          reviewId: 2,
          content: '직원분들이 친절하고 가격도 괜찮아요. 돈카츠도 맛있어요!',
          reviewer: ReviewMemberResponse(
            memberId: 102,
            nickname: '맛집탐험가',
            email: 'foodie@example.com',
          ),
          visitedAt: DateTime.now().subtract(const Duration(days: 7)),
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ];
    }
    
    try {
      final url = Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/reviews');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map<ReviewResponse>((json) => ReviewResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get review list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting review list: $e');
    }
  }
  
  /// 리뷰 작성
  static Future<ReviewResponse> createReview({
    required int memberId,
    required String kakaoPlaceId,
    required String content,
    required DateTime visitedAt,
  }) async {
    final reviewCreate = ReviewCreate(
      memberId: memberId,
      kakaoPlaceId: kakaoPlaceId,
      content: content,
      visitedAt: visitedAt,
    );
    
    if (useDummyData) {
      // 더미 응답 데이터
      await Future.delayed(const Duration(seconds: 1));
      
      return ReviewResponse(
        reviewId: DateTime.now().millisecondsSinceEpoch % 10000, // 임의의 ID
        content: content,
        reviewer: ReviewMemberResponse(
          memberId: memberId,
          nickname: '현재 사용자',
          email: 'user@example.com',
        ),
        visitedAt: visitedAt,
        createdAt: DateTime.now(),
      );
    }
    
    try {
      final url = Uri.parse('$baseUrl$apiPrefix/reviews');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reviewCreate.toJson()),
      );
      
      if (response.statusCode == 200) {
        return ReviewResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }
  
  /// 리뷰 수정
  static Future<ReviewResponse> updateReview({
    required int reviewId,
    required String content,
    required DateTime visitedAt,
  }) async {
    final reviewUpdate = ReviewUpdate(
      content: content,
      visitedAt: visitedAt,
    );
    
    if (useDummyData) {
      // 더미 응답 데이터
      await Future.delayed(const Duration(seconds: 1));
      
      return ReviewResponse(
        reviewId: reviewId,
        content: content,
        reviewer: ReviewMemberResponse(
          memberId: 1,
          nickname: '현재 사용자',
          email: 'user@example.com',
        ),
        visitedAt: visitedAt,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      );
    }
    
    try {
      final url = Uri.parse('$baseUrl$apiPrefix/reviews/$reviewId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reviewUpdate.toJson()),
      );
      
      if (response.statusCode == 200) {
        return ReviewResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating review: $e');
    }
  }
  
  /// 리뷰 삭제
  static Future<ReviewDeleteResponse> deleteReview(int reviewId) async {
    if (useDummyData) {
      // 더미 응답 데이터
      await Future.delayed(const Duration(seconds: 1));
      
      return ReviewDeleteResponse(
        message: '리뷰를 삭제하였습니다.',
        reviewId: reviewId,
      );
    }
    
    try {
      final url = Uri.parse('$baseUrl$apiPrefix/reviews/$reviewId');
      final response = await http.delete(url);
      
      if (response.statusCode == 200) {
        return ReviewDeleteResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to delete review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }
  
  /// 특정 리뷰 상세 조회
  static Future<ReviewResponse> getReviewDetail(String kakaoPlaceId, int reviewId) async {
    if (useDummyData) {
      // 더미 응답 데이터
      await Future.delayed(const Duration(seconds: 1));
      
      return ReviewResponse(
        reviewId: reviewId,
        content: '맛있어요! 라멘이 정말 깔끔하고 육수가 진한 편이에요.',
        reviewer: ReviewMemberResponse(
          memberId: 101,
          nickname: '라멘러버',
          email: 'ramen@example.com',
        ),
        visitedAt: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );
    }
    
    try {
      final url = Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/reviews/$reviewId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return ReviewResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get review detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting review detail: $e');
    }
  }
}