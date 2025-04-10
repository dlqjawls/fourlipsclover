import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API 유틸리티 클래스
/// JWT 토큰 관리 및 기타 공통 기능을 제공합니다.
class ApiUtil {
  static final _secureStorage = const FlutterSecureStorage();

  /// JWT 토큰 가져오기 (SecureStorage)
  static Future<String?> getJwtToken() async {
    final token = await _secureStorage.read(key: 'jwt_token');

    // 디버깅을 위해 토큰 존재 여부 출력
    debugPrint('JWT 토큰 존재 여부: ${token != null}');
    if (token == null) {
      debugPrint('경고: JWT 토큰이 SecureStorage에 저장되어 있지 않습니다.');
    }

    return token;
  }

  /// 토큰 유효성 검사
  static bool validateToken(String? token) {
    if (token == null || token.isEmpty) {
      debugPrint('오류: 인증 토큰이 없습니다. 로그인이 필요합니다.');
      return false;
    }
    return true;
  }
}
