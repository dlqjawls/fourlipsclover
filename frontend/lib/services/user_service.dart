import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/user_journey.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class UserService {
  Future<UserProfile> getUserProfile() async {
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
          'Authorization': '$token', // Bearer 추가
        },
      );

      print('=== 응답 정보 ===');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Raw Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        print('Decoded data: $data');

        final jsonData = json.decode(data);
        print('Parsed JSON: $jsonData');

        return UserProfile.fromJson(jsonData);
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('getUserProfile 에러: $e');
      rethrow; // 원래 에러를 그대로 전달
    }
  }
}
