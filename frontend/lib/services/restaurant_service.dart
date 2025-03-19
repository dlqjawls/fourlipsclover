import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class RestaurantService {
  /// ✅ **가게 상세 정보 가져오기 (더미 데이터 & API 연동 대비)**
  static Future<Map<String, dynamic>> fetchRestaurantDetails(String restaurantId) async {
    print("Fetching restaurant details for restaurantId: $restaurantId");

    // 🔄 **더미 데이터 사용 여부 설정**
    bool useDummyData = true; // true면 더미 데이터, false면 API 요청 실행

    if (useDummyData) {
      // ✅ 더미 데이터 버전 (백엔드 연동 전)
      await Future.delayed(const Duration(seconds: 1)); // 가짜 네트워크 지연

      return {
        'id': restaurantId,
        'name': '김쿨라멘',
        'image': 'https://source.unsplash.com/400x300/?ramen',
        'menu': ['라멘', '돈카츠', '덮밥'],
        'address': '서울특별시 강남구 테헤란로 10길 9',
        'phone': '02-1234-5678',
        'business_hours': '11:00 - 22:00',
        'tags': ['#혼밥', '#일식', '#가성비맛집', '#매운맛'], // ✅ 리뷰 데이터 제거
      };
    }

    // 🔄 **API 연동 버전 (백엔드 완료 후 활성화)**
    // final url = Uri.parse("${ApiConstants.baseUrl}/restaurant/$restaurantId");
    //
    // try {
    //   final response = await http.get(url);
    //
    //   if (response.statusCode == 200) {
    //     return jsonDecode(response.body);
    //   } else {
    //     print("Error: 서버 응답 코드 ${response.statusCode}");
    //     return {};
    //   }
    // } catch (e) {
    //   print("API 요청 중 오류 발생: $e");
    //   return {};
    // }
  }
}
