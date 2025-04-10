import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/matching/matching_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();

  // 카카오 로그인 처리
  Future<Map<String, dynamic>> kakaoLogin() async {
    try {
      OAuthToken? token;
      bool isInstalled = await isKakaoTalkInstalled();

      try {
        if (isInstalled) {
          debugPrint('카카오톡 앱으로 로그인 시도');
          token = await UserApi.instance.loginWithKakaoTalk();
          debugPrint('카카오톡 앱 로그인 성공');
        } else {
          debugPrint('카카오톡 앱이 설치되어 있지 않아 웹 로그인 시도');
          token = await UserApi.instance.loginWithKakaoAccount();
          debugPrint('카카오 웹 로그인 성공');
        }
      } catch (error) {
        debugPrint('카카오톡 로그인 실패: $error');
        // 앱 로그인 실패 시 계정 로그인으로 시도
        if (error.toString().contains('NotSupportError') ||
            error.toString().contains(
              'KakaoTalk is installed but not connected',
            )) {
          debugPrint('카카오톡 로그인 실패로 인해 웹 로그인 시도');
          token = await UserApi.instance.loginWithKakaoAccount();
          debugPrint('카카오 웹 로그인 성공');
        } else {
          rethrow;
        }
      }

      if (token == null) {
        throw Exception('카카오 로그인 실패: 토큰을 가져오지 못했습니다.');
      }

      // 카카오 access_token 저장
      await _saveKakaoAccessToken(token.accessToken);

      debugPrint('카카오 사용자 정보 요청 시작');
      final user = await UserApi.instance.me();
      debugPrint('카카오 사용자 정보 요청 성공');

      debugPrint('서버 로그인 처리 시작');
      final loginResult = await _processServerLogin(token.accessToken);
      debugPrint('서버 로그인 처리 성공');

      // 로그인 성공 시 토큰 저장
      final jwtToken = loginResult['jwtToken'];
      if (jwtToken == null) {
        throw Exception('서버 응답에 JWT 토큰이 없습니다.');
      }
      await saveLoginState(true, jwtToken);

      // 토큰 저장 확인 로그
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('jwtToken');
      debugPrint('JWT 토큰 저장 확인: ${savedToken != null ? '성공' : '실패'}');

      return {'jwtToken': jwtToken, 'user': user};
    } catch (error) {
      debugPrint('로그인 오류 발생: $error');
      rethrow;
    }
  }

  // 카카오 계정으로 웹 로그인 (직접 호출 가능한 메서드 추가)
  Future<Map<String, dynamic>> kakaoWebLogin() async {
    OAuthToken? token;
    try {
      debugPrint('카카오 웹 로그인 직접 시도 - 계정으로 로그인 시작');

      try {
        token = await UserApi.instance.loginWithKakaoAccount();
      } catch (e) {
        debugPrint('loginWithKakaoAccount 첫 번째 시도 실패: $e');
        // 첫 번째 시도가 실패하면 약간의 지연 후 다시 시도
        await Future.delayed(const Duration(milliseconds: 500));
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      debugPrint('카카오 웹 로그인 성공');

      if (token == null) {
        throw Exception('카카오 웹 로그인 실패: 토큰을 가져오지 못했습니다.');
      }

      debugPrint('카카오 사용자 정보 요청 시작');
      final user = await UserApi.instance.me();
      debugPrint('카카오 사용자 정보 요청 성공');

      debugPrint('서버 로그인 처리 시작');
      final loginResult = await _processServerLogin(token.accessToken);
      debugPrint('서버 로그인 처리 성공');

      // 로그인 성공 시 토큰 저장
      final jwtToken = loginResult['jwtToken'];
      if (jwtToken == null) {
        throw Exception('서버 응답에 JWT 토큰이 없습니다.');
      }
      await saveLoginState(true, jwtToken);

      return {'jwtToken': jwtToken, 'user': user};
    } catch (error) {
      debugPrint('카카오 웹 로그인 오류 발생: $error');
      rethrow;
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
    if (baseUrl == null) {
      throw Exception('API_BASE_URL이 설정되지 않았습니다.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/kakao/login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('서버 응답 상태 코드: ${response.statusCode}');
      debugPrint('서버 응답 본문: ${response.body}');

      switch (response.statusCode) {
        case 200:
          final responseData = jsonDecode(response.body);
          if (responseData['jwtToken'] == null) {
            throw Exception('서버 응답에 JWT 토큰이 없습니다.');
          }

          // 로그인 성공 후 매칭 목록 초기화
          try {
            await MatchingService.initializeMatches();
            debugPrint('매칭 목록 초기화 성공');
          } catch (e) {
            debugPrint('매칭 목록 초기화 실패: $e');
            // 매칭 목록 초기화 실패는 로그인 실패로 처리하지 않음
          }

          debugPrint('로그인 성공');
          debugPrint('accessToken: $accessToken');
          debugPrint('jwtToken: ${responseData['jwtToken']}');
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
      await _secureStorage.delete(key: 'kakao_access_token');
      await clearLoginState();
    } catch (error) {
      debugPrint('로그아웃 실패: $error');
      throw error;
    }
  }

  // 로그인 상태 저장
  Future<void> saveLoginState(bool isLoggedIn, String? jwtToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', isLoggedIn);

      if (jwtToken != null && jwtToken.isNotEmpty) {
        // JWT 토큰을 SecureStorage에 저장
        await _secureStorage.write(key: 'jwt_token', value: jwtToken);

        // JWT 토큰 디코딩 및 memberId 저장
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken);
        final String memberId = decodedToken['sub'];
        await prefs.setString('userId', memberId);

        debugPrint('JWT 토큰 안전하게 저장 완료');
        debugPrint('memberId 저장 완료: $memberId');
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
      await prefs.remove('userId');
      await _secureStorage.delete(key: 'jwt_token');
      debugPrint('로그인 상태 초기화 완료');
    } catch (e) {
      debugPrint('로그인 상태 초기화 중 오류 발생: $e');
    }
  }

  Future<void> _saveKakaoAccessToken(String accessToken) async {
    try {
      await _secureStorage.write(key: 'kakao_access_token', value: accessToken);
      debugPrint('카카오 access_token 저장 완료');
    } catch (e) {
      debugPrint('카카오 access_token 저장 실패: $e');
      throw e;
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      debugPrint('자동 로그인 시도 시작');

      // SecureStorage에서 JWT 토큰 불러오기
      final jwtToken = await _secureStorage.read(key: 'jwt_token');
      debugPrint('저장된 JWT 토큰: ${jwtToken != null ? '존재함' : '없음'}');

      if (jwtToken == null || jwtToken.isEmpty) {
        debugPrint('JWT 토큰이 없음');
        return false;
      }

      // JWT 토큰 유효성 검사
      try {
        final isTokenValid = !JwtDecoder.isExpired(jwtToken);
        debugPrint('JWT 토큰 유효성: $isTokenValid');

        if (!isTokenValid) {
          debugPrint('JWT 토큰이 만료됨');
          await clearLoginState();
          return false;
        }
      } catch (e) {
        debugPrint('JWT 토큰 유효성 검사 실패: $e');
        await clearLoginState();
        return false;
      }

      // 토큰이 유효하면 자동 로그인 성공
      debugPrint('자동 로그인 성공 - 유효한 JWT 토큰 확인됨');
      return true;
    } catch (e) {
      debugPrint('자동 로그인 실패: $e');
      await clearLoginState();
      return false;
    }
  }
}
