import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

import '../models/user_journey.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final bool useDummyData = true; // API 연동 전까지 더미데이터 사용

  Future<UserProfile> getUserProfile(String userId) async {
    if (useDummyData) {
      // 더미 데이터 반환
      await Future.delayed(const Duration(milliseconds: 500));
      return UserProfile(
        memberId: 1,
        id: 'user123',
        nickname: '여행자',
        cloverCount: 42,
        writtenPosts: 15,
        receivedLikes: 45,
        writtenReviews: 8,
        completedJourneys: 3,
        achievements: ['첫 여행 완료', '단골 식당 5곳 달성'],
        currentProgress: 30,
        currentJourney: Journey(
          id: 'journey123',
          title: '서울 맛집 투어',
          description: '서울의 숨은 맛집을 찾아서',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          destinations: ['김쿨라멘', '맛있는 식당', '멋진 카페'],
          progressPercentage: 75,
        ),
      );
    }

    // API 구현
    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/profile'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    if (useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    // API 구현
    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId/profile'),
        body: json.encode(updates),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user profile');
      }
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }
}
