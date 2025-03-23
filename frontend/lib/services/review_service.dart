import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant_models.dart';
import '../models/review_model.dart';
import '../constants/api_constants.dart';

class ReviewService {
  // ✅ .env 파일에서 API 기본 URL을 가져옴
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/restaurant';

  /// ✅ 더미 데이터 포함 여부 (`fetchReviews`만 true, 나머지는 false)
  static bool useDummyDataForReviews = true; // `fetchReviews()`만 더미 데이터 포함
  static bool useDummyDataForOtherApis = false; // 나머지 API는 실제 데이터만 사용

  /// ✅ 리뷰 목록 조회 (API + 더미 데이터 포함)
  static Future<List<Review>> fetchReviews(String restaurantId) async {
    print("📌 리뷰 데이터 요청: restaurantId = $restaurantId");

    List<Review> allReviews = [];

    // ✅ API 요청 실행
    try {
      final url = Uri.parse('$baseUrl$apiPrefix/$restaurantId/reviews');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> apiData = jsonDecode(decodedBody);

        List<Review> apiReviews = apiData.map<Review>((json) {
          return Review.fromResponse(ReviewResponse.fromJson(json));
        }).toList();

        allReviews.addAll(apiReviews);
      } else {
        print("❌ 서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API 요청 실패: $e");
    }

    // ✅ 더미 데이터 추가 (`fetchReviews`만 사용)
    if (useDummyDataForReviews) {
      allReviews.addAll(_generateDummyReviews(restaurantId));
    }

    return allReviews;
  }

  /// ✅ 더미 리뷰 데이터 생성 (광주 하남촌 리뷰 포함)
  static List<Review> _generateDummyReviews(String restaurantId) {
    return [
      Review(
        id: '1001',
        restaurantId: restaurantId,
        userId: 'assets/images/review_image.jpg',
        username: '맛집탐험가',
        title: '순대국밥 정말 맛있어요!',
        content: '국물이 진하고 면발이 쫄깃해요. 강력 추천합니다!',
        imageUrl: 'assets/images/review_image3.jpg',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        visitCount: 4,
        isLocal: true,
        localRank: 5,
        likes: 10,
        dislikes: 1,
        date: DateTime.now().subtract(Duration(days: 2)),
        menu: ['라멘', '돈카츠'],
      ),
      // ✅ 광주 하남촌 리뷰 추가
      Review(
        id: '1003',
        restaurantId: '1605310387', // 광주 하남촌 kakaoPlaceId
        userId: 'dummy_user_3',
        username: '한식러버',
        title: '하남촌 순대국밥 최고!',
        content: '국물이 얼큰하고 깊은 맛이 납니다. 한식 좋아하시면 강추!',
        imageUrl: 'assets/images/review_image2.jpg',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
        visitCount: 3,
        isLocal: true,
        localRank: 4,
        likes: 12,
        dislikes: 2,
        date: DateTime.now().subtract(Duration(days: 5)),
        menu: ['김치찌개'],
      ),
    ];
  }

  /// ✅ 특정 장소의 리뷰 목록 조회 (API 데이터만 사용)
  static Future<List<ReviewResponse>> getReviewList(String kakaoPlaceId) async {
    if (useDummyDataForOtherApis) {
      return [];
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

  /// ✅ 리뷰 작성 (API 데이터만 사용)
  static Future<ReviewResponse> createReview({
    required int memberId,
    required String kakaoPlaceId,
    required String content,
    required DateTime visitedAt,
  }) async {
    if (useDummyDataForOtherApis) {
      return ReviewResponse(
        reviewId: DateTime.now().millisecondsSinceEpoch % 10000,
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
        body: jsonEncode({
          "memberId": memberId,
          "kakaoPlaceId": kakaoPlaceId,
          "content": content,
          "visitedAt": visitedAt.toIso8601String(),
        }),
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

  /// ✅ 리뷰 수정 (API 데이터만 사용)
  static Future<ReviewResponse> updateReview({
    required int reviewId,
    required String content,
    required DateTime visitedAt,
  }) async {
    if (useDummyDataForOtherApis) {
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
        body: jsonEncode({
          "content": content,
          "visitedAt": visitedAt.toIso8601String(),
        }),
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

  /// ✅ 리뷰 삭제 (API 데이터만 사용)
  static Future<bool> deleteReview(int reviewId) async {
    if (useDummyDataForOtherApis) {
      return true;
    }

    try {
      final url = Uri.parse('$baseUrl$apiPrefix/reviews/$reviewId');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
