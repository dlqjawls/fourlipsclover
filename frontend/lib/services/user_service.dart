import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/user_journey.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
class UserService {
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      final baseUrl = dotenv.env['API_BASE_URL'];
      
     
      // 토큰 확인
      print('Token: $token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/mypage/dummy'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': '$token' // Bearer 추가
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);  // UTF-8 디코딩 추가
        final jsonData = json.decode(data);
        return UserProfile.fromJson(jsonData);
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserProfile: $e');
      throw Exception('Error loading user profile: $e');
    }
  }
}
