import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // 카카오 로그인 처리
  Future<Map<String, dynamic>> kakaoLogin() async {
    try {
      OAuthToken? token = await _getKakaoToken();
      if (token == null) {
        throw Exception('카카오 로그인 실패: 토큰을 가져오지 못했습니다.');
      }

      final loginResult = await _processServerLogin(token.accessToken);
      final user = await UserApi.instance.me();

      return {'jwtToken': loginResult['jwttoken'], 'user': user};
    } catch (error) {
      debugPrint('로그인 오류 발생: $error');
      throw error;
    }
  }

  // 카카오 토큰 획득
  Future<OAuthToken?> _getKakaoToken() async {
    bool isInstalled = await isKakaoTalkInstalled();

    try {
      if (isInstalled) {
        return await UserApi.instance.loginWithKakaoTalk();
      } else {
        return await UserApi.instance.loginWithKakaoAccount();
      }
    } catch (error) {
      debugPrint('카카오톡 로그인 실패, 계정 로그인 시도: $error');
      return await UserApi.instance.loginWithKakaoAccount();
    }
  }

  // 서버 로그인 처리
  Future<Map<String, dynamic>> _processServerLogin(String accessToken) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    final response = await http.post(
      Uri.parse('$baseUrl/auth/kakao/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'access_token': accessToken}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint('API URL: $baseUrl');
      throw Exception('서버 응답 오류: ${response.statusCode}');
    }
  }

  // 로그아웃 처리
  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
    } catch (error) {
      debugPrint('카카오 로그아웃 실패: $error');
      throw error;
    }
  }

  // 로그인 상태 저장
  Future<void> saveLoginState(bool isLoggedIn, String? jwtToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    if (jwtToken != null) {
      await prefs.setString('jwtToken', jwtToken);
    }
  }

  // 로그인 상태 불러오기
  Future<Map<String, dynamic>> loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool('isLoggedIn') ?? false,
      'jwtToken': prefs.getString('jwtToken'),
    };
  }
}
