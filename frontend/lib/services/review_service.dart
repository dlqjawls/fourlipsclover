import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/review_model.dart';

class ReviewService {
  /// ✅ 리뷰 목록 조회 API
  static Future<List<Review>> fetchReviews(String restaurantId) async {
    print("리뷰 데이터 요청: restaurantId = $restaurantId");
    await Future.delayed(const Duration(seconds: 1));

    // 🔄 **API 연결 여부를 설정하는 플래그**
    bool useDummyData = true; // true면 더미 데이터, false면 API 요청 실행

    if (useDummyData) {
      // ✅ 더미 데이터 버전 시작
      await Future.delayed(const Duration(seconds: 1)); // 가짜 네트워크 지연

      return [
        Review(
            id: '1',
            restaurantId: restaurantId,
            userId: 'user123',
            username: '사용자1',
            title: '훌륭한 경험!', // ✅ 긍정적인 제목 추가
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
            title: '별로였어요...', // ✅ 부정적인 제목 추가
            content: '조금 별로였어요... 기대했던 맛이 아니었어요. '
                '음식이 생각보다 차갑고, 조리가 덜 된 느낌이었어요. '
                '직원들의 응대도 다소 불친절했고, 주문이 늦게 나왔어요. '
                '가격 대비 만족도가 낮아서 다시 방문하지 않을 것 같아요.',
            likes: 4,
            dislikes: 10,
            visitCount: 1,
            imageUrl: null, // ✅ 이미지 없음 -> 기본 이미지 적용됨
            isLocal: false,
            localRank: 3,
            date: DateTime.now().subtract(Duration(days: 3)),
            menu: ['덮밥']
        ),
        Review(
            id: '3',
            restaurantId: restaurantId,
            userId: 'user789',
            username: '사용자3',
            title: '무난한 맛', // ✅ 중립적인 제목 추가
            content: '괜찮은데 특별하진 않아요.',
            likes: 12,
            dislikes: 3,
            visitCount: 2,
            imageUrl: null,
            isLocal: true,
            localRank: 2,
            date: DateTime.now().subtract(Duration(days: 7)),
            menu: ['라멘', '덮밥']
        ),
        Review(
            id: '4',
            restaurantId: restaurantId,
            userId: 'user555',
            username: '사용자4',
            title: '다시 방문하고 싶어요!', // ✅ 긍정적인 제목 추가
            content: '정말 맛있어요. 또 오고 싶어요!',
            likes: 30,
            dislikes: 1,
            visitCount: 10,
            imageUrl: null,
            isLocal: true,
            localRank: 1,
            date: DateTime.now().subtract(Duration(days: 1)),
            menu: ['덮밥']
        ),
        Review(
            id: '5',
            restaurantId: restaurantId,
            userId: 'user888',
            username: '사용자5',
            title: '아쉬웠던 방문', // ✅ 부정적인 제목 추가
            content: '음식이 차갑고 서비스도 별로였어요.',
            likes: 2,
            dislikes: 8,
            visitCount: 1,
            imageUrl: null,
            isLocal: false,
            localRank: 4,
            date: DateTime.now().subtract(Duration(days: 2)),
            menu: ['돈카츠']
        ),
      ];
      // ✅ 더미 데이터 버전 끝
    }

    // 🔄 API 요청 실행
    // try {
    //   final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.reviewsEndpoint}?restaurantId=$restaurantId");
    //   final response = await http.get(url);
    //
    //   if (response.statusCode == 200) {
    //     List<dynamic> data = jsonDecode(response.body);
    //
    //     return data.map<Review>((review) {
    //       return Review(
    //         id: review['id'],
    //         restaurantId: review['restaurant_id'],
    //         userId: review['user_id'],
    //         username: review['username'],
    //         title: review['title'] ?? '리뷰', // ✅ API에서도 title 가져오기
    //         content: review['content'],
    //         likes: review['likes'],
    //         dislikes: review['dislikes'],
    //         visitCount: review['visit_count'],
    //         imageUrl: review['image_url'] ?? 'assets/images/logo.png', // ✅ 기본 이미지 적용
    //         isLocal: review['is_local'],
    //         localRank: review['local_rank'],
    //         date: DateTime.parse(review['date']),
    //         menu: (review['menu'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    //       );
    //     }).toList();
    //   } else {
    //     print("❌ 서버 오류: ${response.statusCode}");
    //     return [];
    //   }
    // } catch (e) {
    //   print("❌ API 요청 중 오류 발생: $e");
    //   return [];
    // }
  }
}
