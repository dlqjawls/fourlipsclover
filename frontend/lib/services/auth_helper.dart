import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT 토큰 관련 헬퍼 클래스
/// 모든 서비스에서 토큰을 가져올 때 사용할 수 있습니다.
class AuthHelper {
  static final _secureStorage = const FlutterSecureStorage();

  /// JWT 토큰 가져오기
  /// SecureStorage에서 JWT 토큰을 가져옵니다.
  static Future<String?> getJwtToken() async {
    final token = await _secureStorage.read(key: 'jwt_token');

    if (token == null) {
      debugPrint('⚠️ JWT 토큰이 없습니다. 로그인이 필요합니다.');
    }

    return token;
  }

  /// 토큰 유효성 검사
  static bool validateToken(String? token) {
    if (token == null || token.isEmpty) {
      debugPrint('❌ 인증 토큰이 없습니다. 로그인이 필요합니다.');
      return false;
    }
    return true;
  }
}
