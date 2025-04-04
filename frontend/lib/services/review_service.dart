import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ReviewService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/restaurant';

  /// ✅ 리뷰 목록 조회
  static Future<List<Review>> fetchReviews(String restaurantId) async {
    print("📌 리뷰 데이터 요청: restaurantId = $restaurantId");

    List<Review> allReviews = [];

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

    return allReviews;
  }

  /// ✅ 리뷰 상세 조회
  static Future<ReviewResponse> getReviewDetail({
    required String kakaoPlaceId,
    required int reviewId,
  }) async {
    final url = Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/reviews/$reviewId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return ReviewResponse.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('리뷰 상세 조회 실패: ${response.statusCode}');
    }
  }

  /// ✅ 리뷰 목록 조회 (리뷰Response 형태)
  static Future<List<ReviewResponse>> getReviewList(String kakaoPlaceId) async {
    try {
      final url = Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/reviews');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map<ReviewResponse>((json) =>
            ReviewResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get review list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting review list: $e');
    }
  }

  /// ✅ 리뷰 작성
  static Future<ReviewResponse> createReview({
    required int memberId,
    required String kakaoPlaceId,
    required String content,
    required DateTime visitedAt,
    File? imageFile,
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl$apiPrefix/reviews');
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $accessToken';

    final jsonMap = {
      "memberId": memberId,
      "kakaoPlaceId": kakaoPlaceId,
      "content": content,
      "visitedAt": visitedAt.toIso8601String(),
    };
    final jsonString = jsonEncode(jsonMap);
    final jsonBytes = utf8.encode(jsonString);

    request.files.add(http.MultipartFile.fromBytes(
      'data',
      jsonBytes,
      contentType: MediaType('application', 'json'),
      filename: 'data.json',
    ));

    if (imageFile != null) {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        imageFile.path,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('🔎 응답코드: ${response.statusCode}');
    print('📦 응답본문: ${response.body}');

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return ReviewResponse.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('리뷰 등록 실패: ${response.statusCode} ${response.body}');
    }
  }

  /// ✅ 리뷰 수정
  static Future<ReviewResponse> updateReview({
    required int reviewId,
    required String content,
    required DateTime visitedAt,
    required String accessToken,
  }) async {
    print("📦 수정 요청 reviewId: $reviewId");
    print("✏️ 수정 내용: $content");
    print("📅 방문일시: ${visitedAt.toIso8601String()}");
    print("🔐 토큰: $accessToken");

    try {
      final url = Uri.parse('$baseUrl$apiPrefix/reviews/$reviewId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "content": content,
          "visitedAt": visitedAt.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return ReviewResponse.fromJson(jsonDecode(decodedBody));
      } else {
        throw Exception('Failed to update review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating review: $e');
    }
  }

  /// ✅ 리뷰 삭제
  static Future<bool> deleteReview({
    required int reviewId,
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl$apiPrefix/reviews/$reviewId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    return response.statusCode == 200;
  }

  /// ✅ 좋아요/싫어요
  static Future<String> toggleLikeStatus({
    required int reviewId,
    required int memberId,
    required String likeStatus,
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl$apiPrefix/reviews/$reviewId/like');

    print("🚀 요청 URL: $url");
    print("📩 요청 데이터: memberId=$memberId, likeStatus=$likeStatus");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "memberId": memberId,
        "likeStatus": likeStatus,
      }),
    );

    print("📬 응답 코드: ${response.statusCode}");
    print("📬 응답 바디: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["message"] ?? "처리 완료";
    } else {
      throw Exception('좋아요/싫어요 처리 실패: ${response.statusCode}');
    }
  }
}
