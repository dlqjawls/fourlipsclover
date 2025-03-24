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

      // 로그인 성공 시 토큰 저장
      final jwtToken = loginResult['jwtToken'];
      await saveLoginState(true, jwtToken);

      // 토큰 저장 확인 로그
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('jwtToken');
      debugPrint('JWT 토큰 저장 확인: ${savedToken != null ? '성공' : '실패'}');

      return {'jwtToken': jwtToken, 'user': user};
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
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/kakao/login'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('서버 연결 시간 초과');
            },
          );

      switch (response.statusCode) {
        case 200:
          final responseData = jsonDecode(response.body);
          if (responseData['jwtToken'] == null) {
            throw Exception('서버 응답에 JWT 토큰이 없습니다.');
          }
          debugPrint('로그인 성공');
          debugPrint(accessToken);
          debugPrint(responseData['jwtToken']);
          return responseData;
        case 401:
          throw Exception('인증 실패: 유효하지 않은 토큰');
        case 403:
          throw Exception('접근 권한이 없습니다.');
        default:
          throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API URL: $baseUrl');
      debugPrint('서버 로그인 처리 중 오류: $e');
      throw e;
    }
  }

  // 로그아웃 처리
  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
      await clearLoginState(); // 로그아웃 시 SharedPreferences에서 모든 로그인 데이터 제거
    } catch (error) {
      debugPrint('카카오 로그아웃 실패: $error');
      throw error;
    }
  }

  // 로그인 상태 저장
  Future<void> saveLoginState(bool isLoggedIn, String? jwtToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', isLoggedIn);

      if (jwtToken != null && jwtToken.isNotEmpty) {
        await prefs.setString('jwtToken', jwtToken);
        debugPrint('JWT 토큰 저장 완료. 토큰 길이: ${jwtToken.length}');
      } else {
        debugPrint('경고: 저장하려는 JWT 토큰이 null이거나 비어 있습니다.');
      }
    } catch (e) {
      debugPrint('로그인 상태 저장 중 오류 발생: $e');
      throw e;
    }
  }

  // 로그인 상태 불러오기
  Future<Map<String, dynamic>> loadLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final jwtToken = prefs.getString('jwtToken');

      debugPrint(
        '로그인 상태 로드: 로그인=${isLoggedIn}, 토큰=${jwtToken != null ? '존재함' : '없음'}',
      );

      return {'isLoggedIn': isLoggedIn, 'jwtToken': jwtToken};
    } catch (e) {
      debugPrint('로그인 상태 로드 중 오류 발생: $e');
      return {'isLoggedIn': false, 'jwtToken': null};
    }
  }

  // 로그인 상태 초기화 (로그아웃 시 호출)
  Future<void> clearLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('jwtToken');
      debugPrint('로그인 상태 초기화 완료');
    } catch (e) {
      debugPrint('로그인 상태 초기화 중 오류 발생: $e');
    }
  }
}
