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

  /// ✅ 리뷰 목록 조회 (accessToken 포함 가능)
  static Future<List<Review>> fetchReviews(String kakaoPlaceId, {String? accessToken}) async {
    print("📍 리뷰 데이터 요청: restaurantId = $kakaoPlaceId");

    List<Review> allReviews = [];

    try {
      final url = Uri.parse('$baseUrl$apiPrefix/$kakaoPlaceId/reviews');
      final headers = {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        print("🔎 응답 바디:\n$decodedBody");

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
    List<File>? imageFiles,
    required String accessToken,
    int amount = 0,
    int visitedPersonnel = 1,
    DateTime? paidAt,
  }) async {
    final url = Uri.parse('$baseUrl$apiPrefix/reviews');
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $accessToken';

    String toIso8601WithoutMicroseconds(DateTime dt) {
      return dt.toIso8601String().split('.').first;
    }

    final jsonMap = {
      "memberId": memberId,
      "kakaoPlaceId": kakaoPlaceId,
      "content": content,
      "visitedAt": toIso8601WithoutMicroseconds(visitedAt),
      "amount": amount,
      "visitedPersonnel": visitedPersonnel,
      "paidAt": toIso8601WithoutMicroseconds(paidAt ?? visitedAt),
    };
    final jsonString = jsonEncode(jsonMap);
    final jsonBytes = utf8.encode(jsonString);
    print('[💾 리뷰 JSON 데이터] ${jsonString}');

    request.files.add(http.MultipartFile.fromBytes(
      'data',
      jsonBytes,
      contentType: MediaType('application', 'json'),
      filename: 'data.json',
    ));

    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (var imageFile in imageFiles) {
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final mimeParts = mimeType.split('/');
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          imageFile.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        ));
      }
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

  /// ✅ 리뷰 수정 (이미지 추가/삭제 지원)
  static Future<ReviewResponse> updateReview({
    required int reviewId,
    required String content,
    required DateTime visitedAt,
    List<String> deleteImageUrls = const [],
    List<File> newImages = const [],
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl$apiPrefix/reviews/$reviewId');
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $accessToken';

    // ✅ JSON 본문을 문자열로 전송
    final dataMap = {
    "content": content,
    "visitedAt": visitedAt.toIso8601String(),
    };
    final jsonString = jsonEncode({
      "content": content,
      "visitedAt": visitedAt.toIso8601String(),
    });
    request.files.add(http.MultipartFile.fromBytes(
      'data',
      utf8.encode(jsonString),
      filename: 'data.json',
      contentType: MediaType('application', 'json'),
    ));

    final trimmedDeleteUrls = deleteImageUrls
        .map((url) => Uri.decodeComponent(url.split('/').last))
        .toList();

    if (trimmedDeleteUrls.isNotEmpty) {
      final deleteJson = jsonEncode(trimmedDeleteUrls);
      request.files.add(http.MultipartFile.fromBytes(
        'deleteImageUrls',
        utf8.encode(deleteJson),
        filename: 'deleteImageUrls.json',
        contentType: MediaType('application', 'json'),
      ));
    }



    // ✅ 새 이미지 파일 추가
    for (final image in newImages) {
    final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
    final parts = mimeType.split('/');
    request.files.add(await http.MultipartFile.fromPath(
    'images',
    image.path,
    contentType: MediaType(parts[0], parts[1]),
    ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decodedBody = utf8.decode(response.bodyBytes);

    print("응답코드: ${response.statusCode}");
    print("응답본문: $decodedBody");

    if (response.statusCode == 200) {
    return ReviewResponse.fromJson(jsonDecode(decodedBody));
    } else {
    throw Exception("리뷰 수정 실패: ${response.statusCode} $decodedBody");
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
