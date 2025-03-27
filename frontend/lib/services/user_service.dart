import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';

class UserService {
  final UserProvider userProvider;

  UserService({required this.userProvider});

  Future<UserProfile> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      final baseUrl = dotenv.env['API_BASE_URL'];

      final response = await http.get(
        Uri.parse('$baseUrl/api/mypage/dummy'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(data);
        final userProfile = UserProfile.fromJson(jsonData);

        userProvider.setUserProfile(userProfile);
        return userProfile;
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('getUserProfile 에러: $e');
      rethrow;
    }
  }
}
